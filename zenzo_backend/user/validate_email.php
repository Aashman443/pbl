<?php
include '../connection.php';

header('Content-Type: application/json');

if (isset($_POST['EMAIL'])) {
    $email = $_POST['EMAIL'];

    // Use a placeholder (?) in the SQL query
    $sqlQuery = "SELECT * FROM users_table WHERE user_email = ?";
    $stmt = $connectNow->prepare($sqlQuery);

    if ($stmt) {
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $resultQuery = $stmt->get_result();

        if ($resultQuery->num_rows > 0) {
            // Email already exists
            echo json_encode(array("emailFound" => true));
        } else {
            // Email is available
            echo json_encode(array("emailFound" => false));
        }

        $stmt->close();
    } else {
        echo json_encode(array("error" => "Prepare failed: " . $connectNow->error));
    }
} else {
    echo json_encode(array("error" => "EMAIL parameter missing"));
}
?>
