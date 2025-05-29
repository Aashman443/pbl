<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');

$serverHost = "localhost";
$user = "root";
$password = "root";
$database = "Zenzo_app";

$connectNow = new mysqli($serverHost, $user, $password, $database);

if ($connectNow->connect_error) {
    echo json_encode(["success" => false, "error" => "Connection failed: " . $connectNow->connect_error]);
    exit();
}

// Get input
$data = json_decode(file_get_contents("php://input"), true);
$email = isset($data['email']) ? trim($data['email']) : "";
$product_id = isset($data['product_id']) ? trim($data['product_id']) : "";

if (empty($email) || empty($product_id)) {
    echo json_encode(["success" => false, "error" => "Email and product_id are required"]);
    exit();
}

// Prepare statement to remove by email and product_id
$stmt = $connectNow->prepare("DELETE FROM favorite WHERE email = ? AND product_id = ?");
$stmt->bind_param("ss", $email, $product_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "Item removed from favorites"]);
    } else {
        echo json_encode(["success" => false, "message" => "No item found with provided email and product_id"]);
    }
} else {
    echo json_encode(["success" => false, "error" => "Error deleting item: " . $stmt->error]);
}

$stmt->close();
$connectNow->close();
?>
