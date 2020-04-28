
<?
$host = 'localhost'; 
$user = 'root'; 
$pw = 'apmsetup';
$dbName = 'detectdb'; 
$mysqli = new mysqli($host, $user, $pw, $dbName); 


if (mysqli_connect_errno()){ 
    echo "ERROR: 데이타베이스에 연결할 수 없습니다.";
    exit;
}

$distance = $_GET["distance"];
$field_id = $_GET["field_id"];

$query = "INSERT INTO arduino_db (distance, field_id) VALUES ('".$distance."', '".$field_id."')";


$result = mysqli_query($mysqli, $query);


if ($result) {
    echo $db->affected_rows." data inserted into databases.";
}else{
    echo "ERROR: 자료가 추가되지 않았습니다.";
}

mysqli_close($mysqli);


?> 
<script>

   setTimeout("history.go(0);", 10);

</script>
