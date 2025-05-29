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

// Get JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate required fields
$required = ['email', 'full_name', 'phone_number', 'pincode', 'state', 'city', 'house_details', 'road_details'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        echo json_encode(["success" => false, "error" => "$field is required"]);
        exit();
    }
}

// Escape and assign fields
$email = $connectNow->real_escape_string($data['email']);
$full_name = $connectNow->real_escape_string($data['full_name']);
$phone_number = $connectNow->real_escape_string($data['phone_number']);
$alternate_phone = $connectNow->real_escape_string($data['alternate_phone'] ?? '');
$pincode = $connectNow->real_escape_string($data['pincode']);
$state = $connectNow->real_escape_string($data['state']);
$city = $connectNow->real_escape_string($data['city']);
$house = $connectNow->real_escape_string($data['house_details']);
$road = $connectNow->real_escape_string($data['road_details']);

// SQL Insert
$sql = "INSERT INTO addresses (email, full_name, phone_number, alternate_phone, pincode, state, city, house_details, road_details)
        VALUES ('$email', '$full_name', '$phone_number', '$alternate_phone', '$pincode', '$state', '$city', '$house', '$road')";

if ($connectNow->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Address saved successfully"]);
} else {
    echo json_encode(["success" => false, "error" => "Database insert failed"]);
}

$connectNow->close();
?>
