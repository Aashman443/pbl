<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');

$serverHost = "localhost";
$user = "root";
$password = "root";
$database = "Zenzo_app";

$connectNow = new mysqli($serverHost, $user, $password, $database);

if ($connectNow->connect_error) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $connectNow->connect_error]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

$order_id = $data["id"] ?? '';
$new_status = $data["status"] ?? '';

if (empty($order_id) || empty($new_status)) {
    echo json_encode(["success" => false, "message" => "Missing order ID or status"]);
    exit();
}

$stmt = $connectNow->prepare("UPDATE orders SET status = ? WHERE id = ?");
$stmt->bind_param("si", $new_status, $order_id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Order status updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to update order status"]);
}

$stmt->close();
$connectNow->close();
?>
