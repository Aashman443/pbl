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
    echo json_encode(["success" => false, "error" => "Connection failed: " . $connectNow->connect_error]);
    exit();
}

// Get input
$data = json_decode(file_get_contents("php://input"), true);
$email = isset($data['email']) ? trim($data['email']) : "";

if (empty($email)) {
    echo json_encode(["success" => false, "error" => "Email is required"]);
    exit();
}

// Prepare statement
$stmt = $connectNow->prepare("SELECT * FROM favorite WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

$favoriteItems = [];

while ($row = $result->fetch_assoc()) {
    $row['images'] = json_decode($row['images']);
    $favoriteItems[] = $row;
}

if (!empty($favoriteItems)) {
    echo json_encode(["success" => true, "favorite" => $favoriteItems]);
} else {
    echo json_encode(["success" => true, "favorite" => [], "message" => "No items found in favorites"]);
}

$stmt->close();
$connectNow->close();
?>
