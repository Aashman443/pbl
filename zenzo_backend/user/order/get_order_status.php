<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$serverHost = "localhost";
$user = "root";
$password = "root";
$database = "Zenzo_app";

$connectNow = new mysqli($serverHost, $user, $password, $database);

if ($connectNow->connect_error) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $connectNow->connect_error]);
    exit();
}

// Check if the request is GET and order_id is provided
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['order_id']) && !empty($_GET['order_id'])) {
        $order_id = $connectNow->real_escape_string($_GET['order_id']);

        // Prepare the query
        $stmt = $connectNow->prepare("SELECT id, status, created_at, updated_at FROM orders WHERE id = ?");
        $stmt->bind_param("i", $order_id);
        $stmt->execute();

        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $orderData = $result->fetch_assoc();
            echo json_encode([
                "success" => true,
                "data" => [
                    "order_id" => $orderData['id'],
                    "status" => $orderData['status'],
                    "created_at" => $orderData['created_at'],
                    "updated_at" => $orderData['updated_at'] ?? $orderData['created_at']
                ],
                "message" => "Order status retrieved successfully"
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Order not found"
            ]);
        }

        $stmt->close();
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Order ID is required"
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Only GET method allowed"
    ]);
}

$connectNow->close();
?>
