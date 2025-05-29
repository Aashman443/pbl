<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");

// Database credentials
$serverHost = "localhost";
$user = "root";
$password = "root";
$database = "Zenzo_app";

// Connect to the database
$connectNow = new mysqli($serverHost, $user, $password, $database);

// Check connection
if ($connectNow->connect_error) {
    echo json_encode(["success" => false, "error" => "Connection failed: " . $connectNow->connect_error]);
    exit();
}

// Get email from query params (GET method)
$email = isset($_GET['email']) ? $connectNow->real_escape_string($_GET['email']) : '';

if (empty($email)) {
    echo json_encode(["success" => false, "error" => "Email is required"]);
    exit();
}

// Query to fetch addresses by email
$sql = "SELECT * FROM addresses WHERE email = '$email'";
$result = $connectNow->query($sql);

if ($result->num_rows > 0) {
    $addresses = [];
    while ($row = $result->fetch_assoc()) {
        $addresses[] = $row;
    }
    echo json_encode(["success" => true, "addresses" => $addresses]);
} else {
    echo json_encode(["success" => false, "message" => "No addresses found"]);
}

$connectNow->close();
?>
