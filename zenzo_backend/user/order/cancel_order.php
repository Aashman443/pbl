<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Turn off PHP errors output to prevent unexpected characters
error_reporting(0);
ini_set('display_errors', 0);

$serverHost = "localhost";
$user = "root";
$password = "root";
$database = "Zenzo_app";

$connectNow = new mysqli($serverHost, $user, $password, $database);

if ($connectNow->connect_error) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $connectNow->connect_error]);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $inputJSON = file_get_contents('php://input');
    $input = json_decode($inputJSON, true);
    
    $order_id = $input['order_id'] ?? '';

    if (!empty($order_id)) {
        $order_id = $connectNow->real_escape_string($order_id);

        $stmt = $connectNow->prepare("SELECT id, status FROM orders WHERE id = ?");
        $stmt->bind_param("i", $order_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result && $result->num_rows > 0) {
            $orderData = $result->fetch_assoc();
            $currentStatus = strtolower($orderData['status']);

            if ($currentStatus === 'cancelled') {
                echo json_encode([
                    "success" => false,
                    "message" => "Order is already cancelled"
                ]);
            } elseif (in_array($currentStatus, ['completed', 'shipped'])) {
                echo json_encode([
                    "success" => false,
                    "message" => "Order cannot be cancelled as it is already " . $currentStatus
                ]);
            } else {
                $updateStmt = $connectNow->prepare("UPDATE orders SET status = 'cancelled', updated_at = NOW() WHERE id = ?");
                $updateStmt->bind_param("i", $order_id);

                if ($updateStmt->execute()) {
                    echo json_encode([
                        "success" => true,
                        "message" => "Order cancelled successfully"
                    ]);
                } else {
                    echo json_encode([
                        "success" => false,
                        "message" => "Failed to cancel order. Please try again."
                    ]);
                }
                $updateStmt->close();
            }
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
        "message" => "Only POST method allowed"
    ]);
}

$connectNow->close();
?>
