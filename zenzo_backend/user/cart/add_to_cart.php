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

$data = json_decode(file_get_contents("php://input"), true);

// Escape and sanitize input
$email = $connectNow->real_escape_string($data['email']);
$product_id = $connectNow->real_escape_string($data['product_id']);
$title = $connectNow->real_escape_string($data['title']);
$brand_name = $connectNow->real_escape_string($data['brand_name']);
$description = $connectNow->real_escape_string($data['description']);
$price = $connectNow->real_escape_string($data['price']);
$rating = $connectNow->real_escape_string($data['rating']);
$images = $connectNow->real_escape_string(json_encode($data['images']));
$selected_size = $connectNow->real_escape_string($data['selected_size']);
$selected_color = $connectNow->real_escape_string($data['selected_color']);

// Insert into cart
$sql = "INSERT INTO cart (
    email, product_id, title, brand_name, description, price, rating, images, selected_size, selected_color
) VALUES (
    '$email', '$product_id', '$title', '$brand_name', '$description', '$price', '$rating', '$images', '$selected_size', '$selected_color'
)";

if ($connectNow->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Added to cart"]);
} else {
    echo json_encode(["success" => false, "error" => $connectNow->error]);
}

$connectNow->close();
?>
