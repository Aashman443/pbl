<?php
// Enable error reporting (optional for debugging)
ini_set('display_errors', 0);
error_reporting(E_ALL);

// Set response header to JSON
header('Content-Type: application/json');

try {
    include '../connection.php';

    if (!isset($connectNow) || $connectNow->connect_error) {
        throw new Exception("Database connection failed: " . ($connectNow->connect_error ?? "Connection variable not set"));
    }

    $sql = "SELECT * FROM products ORDER BY id DESC";
    $result = $connectNow->query($sql);

    if (!$result) {
        throw new Exception("Failed to fetch products: " . $connectNow->error);
    }

    $products = [];
    $host = $_SERVER['HTTP_HOST']; // gets correct host from request
    $baseImageUrl = "http://$host/zenzo/"; // ✅ change to your actual URL

    while ($row = $result->fetch_assoc()) {
        $images = json_decode($row['images'], true);
        $sizes = json_decode($row['sizes'], true);
        $colors = json_decode($row['colors'], true);

        // Convert image filenames to full URLs
        $fullImageUrls = [];
        if (is_array($images)) {
            foreach ($images as $img) {
                $fullImageUrls[] = $baseImageUrl . $img;
            }
        }

        $row['images'] = $fullImageUrls;
        $row['sizes'] = $sizes;
        $row['colors'] = $colors;

        $products[] = $row;
    }

    echo json_encode([
        'success' => true,
        'products' => $products
    ]);

    $connectNow->close();

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>
