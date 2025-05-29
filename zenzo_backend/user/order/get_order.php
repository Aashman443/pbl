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

if ($data === null) {
    echo json_encode(["success" => false, "message" => "Invalid JSON body."]);
    exit();
}

$email = $data["email"] ?? '';

if (empty($email)) {
    echo json_encode(["success" => false, "message" => "Email is required."]);
    exit();
}

$stmt = $connectNow->prepare("SELECT id, email, full_name, phone_number, alternate_phone, address_type, address_text, payment_method, subtotal, delivery_fee, total, product_name, product_image, size, color, quantity, price, order_date FROM orders WHERE email = ? ORDER BY order_date DESC");

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $connectNow->error]);
    exit();
}

$stmt->bind_param("s", $email);

if (!$stmt->execute()) {
    echo json_encode(["success" => false, "message" => "Execute failed: " . $stmt->error]);
    exit();
}

$result = $stmt->get_result();

$orders = [];

while ($row = $result->fetch_assoc()) {
    $orders[] = $row;
}

if (!empty($orders)) {
    echo json_encode(["success" => true, "orders" => $orders]);
} else {
    echo json_encode(["success" => false, "message" => "No orders found for this email."]);
}

$stmt->close();
$connectNow->close();
?>
