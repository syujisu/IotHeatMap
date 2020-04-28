#필요한 라이브러리
install.packages("jpeg")
install.packages("rgdal")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyr")
install.packages("stringr")
install.packages("grid")
install.packages("animation")
install.packages("gganimate")
install.packages('lubridate')
library(jpeg)
library(rgdal)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(grid)
library(animation)
library(gganimate)
library(lubridate)

#클라우드 데이터 불러오기 (csv)
cloudData = read.csv('C:/Users/user/python 3.5/py_temp/Iot/sc/final.csv', header = TRUE)

#timestamp + field data (비율 정제 위해 /100)
cData=cbind(cloudData[c(1:2)],cloudData[c(3:9)]/100)

#새로운 csv파일로 변환 저장 -> 불러오기 
write.csv(cData,  "C:/Users/user/python 3.5/py_temp/Iot/sc/a_csv.csv")
a_csv = read.csv('C:/Users/user/python 3.5/py_temp/Iot/sc/a_csv.csv', header = TRUE)

#field별 y좌표 처리  / 결측지 0처리 
a_csv$field1 = 7.5-a_csv$field1
a_csv$field2 = 2.6+a_csv$field2
a_csv$field3 = 7.7-a_csv$field3
a_csv$field4 = 2.5+a_csv$field4
a_csv$field5 = 7.5-a_csv$field5
a_csv$field6 = 2.1+a_csv$field6
a_csv$field7 = 2.4+a_csv$field7
a_csv[is.na(a_csv)] = 0

#field별(아두이노) x좌표 지정 
a_csv[a_csv$field1 != is.na(0.00) , "X"] = 8.2
a_csv[a_csv$field2 != is.na(0.00) , "X"] = 6.8
a_csv[a_csv$field3 != is.na(0.00) , "X"] = 5.8
a_csv[a_csv$field4 != is.na(0.00) , "X"] = 4.4
a_csv[a_csv$field5 != is.na(0.00) , "X"] = 3.5
a_csv[a_csv$field6 != is.na(0.00) , "X"] = 2.7
a_csv[a_csv$field7 != is.na(0.00) , "X"] = 0.2

#데이터프레임에 X, Y, entry_id, created_at만 저장
a_csv$Y = apply(a_csv[4:10],1,sum)
a_csv = cbind(a_csv[c(1:3)],a_csv[c(11)])
a_csv = a_csv[,c(3,2,1,4)]

#field별 지정
a_csv[a_csv$X == 8.2, "Field"] = "센서1"
a_csv[a_csv$X == 6.8, "Field"] = "센서2"
a_csv[a_csv$X == 5.8, "Field"] = "센서3"
a_csv[a_csv$X == 4.4, "Field"] = "센서4"
a_csv[a_csv$X == 3.5, "Field"] = "센서5"
a_csv[a_csv$X == 2.7, "Field"] = "센서6"
a_csv[a_csv$X == 0.2, "Field"] = "센서7"

#시간대별 데이터 처리 위해 created_at 기준 칼럼 생성
a_csv$Time <- substr(a_csv$created_at,12,13)
a_csv[a_csv$Time == 10, "Time"] = "오전10시"
a_csv[a_csv$Time == 11, "Time"] = "오전11시"
a_csv[a_csv$Time == 12, "Time"] = "오후12시"
a_csv[a_csv$Time == 13, "Time"] = "오후1시"
a_csv[a_csv$Time == 14, "Time"] = "오후2시"
a_csv[a_csv$Time == 15, "Time"] = "오후3시"
a_csv[a_csv$Time == 16, "Time"] = "오후4시"

#센서측정시간 시간대별 데이터 처리 위해 created_at type 변경
a_csv$created_at <- as_datetime(a_csv$created_at)

str(a_csv)
a_csv

#시각화===================================================================================
#작업폴더 경로 설정
setwd(file.path("C:", "Users", "user", "python 3.5", "py_temp", "Iot", "sc"))

#이미지 불러오기 (배경)
image_file <- "office.jpg"
img <- readJPEG(image_file)
g <- rasterGrob(img, interpolate=FALSE)

#total 최대 이동경로 파악
g_ct <- ggplot(a_csv, aes(x=X, y=Y, color = Field)) 
+ annotation_custom(g, -Inf, Inf, -Inf, Inf) 
+ scale_x_discrete(breaks = NULL) + scale_y_discrete(breaks = NULL) 
+ geom_jitter(size = 4, alpha = 0.2) 
+ geom_line(size = 1, linetype = 2, col = 1, alpha = 0.6) 
+ coord_cartesian(xlim = c(0.4,11), ylim = c(1,10)) + theme_bw() 
+ labs(title = "Eugene IT Sevice", subtitle = "최대 이동경로 파악", x = "", y = "")
g_ct

#시간대별 이동 경로 
g_at <- ggplot(a_csv, aes(x= X, y= Y, size=7, color=created_at)) 
+ annotation_custom(g, -Inf, Inf, -Inf, Inf) 
+ scale_x_discrete(breaks = NULL) + scale_y_discrete(breaks = NULL) 
+ geom_jitter() + theme_bw() + transition_time(created_at) + ease_aes('linear') 
+ labs(title = "Eugene IT Sevice", subtitle = '시간대별 이동경로: {frame_time} + 9시', x="", y="") 
+ coord_cartesian(xlim = c(0.4,11), ylim = c(1,10))
g_at

#센서 별 움직임 시간대별 누적 카운터 데이터프레임
a_csv1 <- a_csv %>% group_by(Field,Time) %>% summarise(Count=n()) %>% mutate(Freq=Count/sum(Count))
a_csv1

#센서별 Heat map
g_ht <- ggplot(a_csv1, aes(x=Field, y=Time, fill=Count, label=Count)) 
+ scale_x_discrete(limit = c("센서7","센서6","센서5","센서4","센서3","센서2","센서1")) 
+ scale_y_discrete(breaks = NULL) + annotation_custom(g, -Inf, Inf, -Inf, Inf) 
+ geom_raster(alpha=0.5, interpolate=TRUE) + scale_fill_gradient(low = "yellow", high = "red") 
+ coord_cartesian(xlim = c(1,9), ylim = c(-1,11)) + theme_bw() 
+ labs(title = "Eugene IT Sevice", subtitle = "센서별 Heat map", x = " ", y = " ") 
+ theme(panel.border = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank())
g_ht

