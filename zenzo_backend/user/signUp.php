<?php
include '../connection.php';

$userName = $_POST['user_name'];
$userEmail = $_POST['user_email'];
$userPassword = md5($_POST['user_password']);  // Ideally switch to password_hash() later

$stmt = $connectNow->prepare("INSERT INTO users_table (user_name, user_email, user_password) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $userName, $userEmail, $userPassword);

if ($stmt->execute()) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false, "error" => $stmt->error));
}

$stmt->close();
?>
