<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');

$serverHost = "localhost";
$user = "root";
$password = "root";
$database = "Zenzo_app";

$connectNow = new mysqli($serverHost, $user, $password, $database);

// Check connection
if ($connectNow->connect_error) {
    echo json_encode(array("success" => false, "error" => "Connection failed: " . $connectNow->connect_error));
    exit();
}
