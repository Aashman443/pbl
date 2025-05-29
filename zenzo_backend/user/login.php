<?php
include '../connection.php'; // Ensure this is the correct path for your DB connection

// Get POST data
$userEmail = $_POST['user_email'];
$userPassword = md5($_POST['user_password']);  // Hashing password to match signup method

// Prepare SQL statement
$stmt = $connectNow->prepare("SELECT user_id, user_name, user_email FROM users_table WHERE user_email = ? AND user_password = ?");
$stmt->bind_param("ss", $userEmail, $userPassword);

// Execute the query
$stmt->execute();
$result = $stmt->get_result();

// Check if any user is found
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();  // Fetch only the first matching row

    // Respond with the user info, including user_id
    echo json_encode(array(
        "success" => true,
        "user_id" => $user['user_id'],
        "user_name" => $user['user_name'],
        "user_email" => $user['user_email']
    ));
} else {
    // No user found, return failure
    echo json_encode(array("success" => false, "message" => "Invalid email or password"));
}

// Close the statement
$stmt->close();
?>
