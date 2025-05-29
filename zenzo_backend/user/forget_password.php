<?php
include '../connection.php';

header('Content-Type: application/json');

if (isset($_POST['EMAIL']) && isset($_POST['NEW_PASSWORD'])) {
    $email = $_POST['EMAIL'];
    $newPassword = md5($_POST['NEW_PASSWORD']);  // use md5 because your signup/login uses it

    $sqlQuery = "UPDATE users_table SET user_password = ? WHERE user_email = ?";
    $stmt = $connectNow->prepare($sqlQuery);

    if ($stmt) {
        $stmt->bind_param("ss", $newPassword, $email);
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                echo json_encode(array("success" => true, "message" => "Password updated successfully."));
            } else {
                echo json_encode(array("success" => false, "message" => "No user found or password unchanged."));
            }
        } else {
            echo json_encode(array("success" => false, "message" => "Execute failed: " . $stmt->error));
        }
        $stmt->close();
    } else {
        echo json_encode(array("success" => false, "message" => "Prepare failed: " . $connectNow->error));
    }
} else {
    echo json_encode(array("success" => false, "message" => "EMAIL or NEW_PASSWORD parameter missing"));
}
?>
