<?php
include '../connection.php'; // Ensure this is the correct path for your DB connection

// Get POST data
$adminEmail = $_POST['admin_email'];
$adminPassword = $_POST['admin_password'];  // Hashing password to match signup method

// Prepare SQL statement
$stmt = $connectNow->prepare("SELECT admin_id,admin_name, admin_email FROM admin_table WHERE admin_email = ? AND admin_password = ?");
$stmt->bind_param("ss", $adminEmail, $adminPassword);

// Execute the query
$stmt->execute();
$result = $stmt->get_result();

// Check if any user is found
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();  // Fetch only the first matching row

    // Respond with the user info
    echo json_encode(array(
        "success" => true,
        "admin_name" => $user['admin_name'],
        "admin_email" => $user['admin_email']
    ));
} else {
    // No user found, return failure
    echo json_encode(array("success" => false, "message" => "Invalid email or password"));
}

// Close the statement
$stmt->close();
?>
