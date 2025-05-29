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

// Getting POST data
$data = json_decode(file_get_contents("php://input"), true);

$email = $data["email"] ?? '';
$fullName = $data["full_name"] ?? '';
$phoneNumber = $data["phone_number"] ?? '';
$altPhone = $data["alternate_phone"] ?? '';
$addressType = $data["address_type"] ?? '';
$addressText = $data["address_text"] ?? '';
$paymentMethod = $data["payment_method"] ?? '';
$subtotal = $data["subtotal"] ?? 0.0;
$deliveryFee = $data["delivery_fee"] ?? 0.0;
$total = $data["total"] ?? 0.0;
$status = $data["status"] ?? 'pending';   // default 'pending' status if not provided
$items = $data["items"] ?? [];

$allInserted = true;

foreach ($items as $item) {
    $stmt = $connectNow->prepare("INSERT INTO orders (
        email, full_name, phone_number, alternate_phone, address_type, address_text,
        payment_method, subtotal, delivery_fee, total,
        product_name, product_image, size, color, quantity, price, status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Prepare failed: " . $connectNow->error]);
        exit();
    }

    $stmt->bind_param(
        "sssssssdddsssisis", 
        $email,
        $fullName,
        $phoneNumber,
        $altPhone,
        $addressType,
        $addressText,
        $paymentMethod,
        $subtotal,
        $deliveryFee,
        $total,
        $item["product_name"],
        $item["product_image"],
        $item["size"],
        $item["color"],
        $item["quantity"],
        $item["price"],
        $status
    );

    if (!$stmt->execute()) {
        $allInserted = false;
        break;
    }

    $stmt->close();
}

if ($allInserted) {
    echo json_encode(["success" => true, "message" => "Order placed successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Error inserting order item."]);
}

$connectNow->close();
?>
