#필요한 라이브러리
install.packages("jpeg")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyr")
install.packages("stringr")
install.packages("animation")
install.packages("gganimate")
install.packages('lubridate')
library(lubridate)
library(animation)
library(gganimate)
library(jpeg)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)


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
a_csv[a_csv$X == 8.2, "field"] = "field1"
a_csv[a_csv$X == 6.8, "field"] = "field2"
a_csv[a_csv$X == 5.8, "field"] = "field3"
a_csv[a_csv$X == 4.4, "field"] = "field4"
a_csv[a_csv$X == 3.5, "field"] = "field5"
a_csv[a_csv$X == 2.7, "field"] = "field6"
a_csv[a_csv$X == 0.2, "field"] = "field7"

#시간대별 데이터 처리 위해 created_at 기준 칼럼 생성
a_csv$Time<-substr(a_csv$created_at,12,13)

#시각화===================================================================================
#작업폴더 경로 설정
setwd(file.path("C:", "Users", "user", "python 3.5", "py_temp", "Iot", "sc"))


#시간대별 데이터 처리 위해 created_at type 변경
a_csv$created_at<-as_datetime(a_csv$created_at)

#이미지 불러오기 (배경)
image_file <- "office.jpg"
img <- readJPEG(image_file)
g <- rasterGrob(img, interpolate=FALSE)

#시간대 별, 움직임 
g_ct <- ggplot(data=a_csv, aes(x=X, y=Y, color = Field)) 
+ annotation_custom(g, -Inf, Inf, -Inf, Inf) + geom_point(size = 10, shape = 1) 
+ geom_line(size = 1, linetype = "dashed", col = 1, alpha = 0.6) 
+ coord_cartesian(xlim = c(0.4,11), ylim = c(1,10)) + theme_bw() 
+ labs(title = "Eugene IT Sevice", subtitle = "이동경로 파악", x = "", y = "")


#가장 많이 움직인 시간 파악
length(which(a_csv$Time == 10)) 
length(which(a_csv$Time == 11))
length(which(a_csv$Time == 12))
length(which(a_csv$Time == 13))
length(which(a_csv$Time == 14))
length(which(a_csv$Time == 15))
length(which(a_csv$Time == 16))

a_time <- data.frame(time = c(10,11,12,13,14,15,16), count = c(13, 195, 191,84,197,201,192))

g_time <- ggplot(a_time, aes(x = time, y = count, colour = count)) 
+ geom_point(aes(size = 0.5)) 
+ geom_line()+ coord_cartesian(ylim = c(1,200)) + theme_bw() 
+ labs(title = "Eugene IT Sevice", subtitle = "가장 많이 움직인 시간 파악
", x = "", y = "")


#시간대별 이동 경로 
ggplot(data=a_csv, aes(x= X, y= Y, size=5, color=created_at)) 
+ annotation_custom(g, -Inf, Inf, -Inf, Inf) + geom_point() 
+ theme_bw() 
+ transition_time(created_at) 
+ ease_aes('linear') + labs(title = '시간대별 이동경로: {frame_time+9}') 
+ coord_cartesian(xlim = c(0.4,11), ylim = c(1,10))


