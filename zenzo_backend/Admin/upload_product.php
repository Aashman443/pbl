<?php
ob_start();
ini_set('display_errors', 0);
error_reporting(E_ALL);

try {
    include '../connection.php';

    if (!isset($connectNow) || $connectNow->connect_error) {
        throw new Exception("Database connection failed: " . ($connectNow->connect_error ?? "Connection variable not set"));
    }

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception("Invalid request method: " . $_SERVER['REQUEST_METHOD']);
    }

    $debug = [
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'post_data' => $_POST,
        'files' => isset($_FILES) ? array_keys($_FILES) : 'No files'
    ];

    if (!isset($_FILES['images']) && !isset($_FILES['images[]'])) {
        throw new Exception("No images uploaded. Available keys: " . implode(", ", array_keys($_FILES)));
    }

    $imageKey = isset($_FILES['images']) ? 'images' : 'images[]';

    $debug['image_key'] = $imageKey;
    $debug['image_data'] = $_FILES[$imageKey];

    $title = $_POST['title'] ?? '';
    $description = $_POST['description'] ?? '';
    $price = $_POST['price'] ?? '';
    $discount = $_POST['discount'] ?? 0;
    $rating = $_POST['rating'] ?? 0;
    $rating = is_numeric($rating) ? min((float)$rating, 5.0) : 0; // Ensure max 5.0

    $brand_name = $_POST['brand_name'] ?? '';
    if ($brand_name === '0' || $brand_name === 0 || empty($brand_name)) {
        $brand_name = 'Unbranded';
    }

    $category = $_POST['category'] ?? '';
    $subcategory = $_POST['subcategory'] ?? '';
    $sizes = $_POST['sizes'] ?? '[]';
    $colors = $_POST['colors'] ?? '[]';
    $is_featured = isset($_POST['is_featured']) && ($_POST['is_featured'] === 'true' || $_POST['is_featured'] === '1') ? 1 : 0;
    $is_new_arrival = isset($_POST['is_new_arrival']) && ($_POST['is_new_arrival'] === 'true' || $_POST['is_new_arrival'] === '1') ? 1 : 0;
    $is_published = isset($_POST['is_published']) && ($_POST['is_published'] === 'true' || $_POST['is_published'] === '1') ? 1 : 0;

    $debug['fields'] = [
        'title' => $title,
        'price' => $price,
        'brand' => $brand_name,
        'category' => $category,
        'subcategory' => $subcategory,
        'sizes' => $sizes,
        'colors' => $colors,
        'rating' => $rating,
    ];

    $uploadDir = "uploads/";
    $imagePaths = [];

    if (!is_dir($uploadDir)) {
        if (!mkdir($uploadDir, 0755, true)) {
            throw new Exception("Failed to create upload directory.");
        }
    }

    foreach ($_FILES[$imageKey]['tmp_name'] as $key => $tmpName) {
        $filename = basename($_FILES[$imageKey]['name'][$key]);
        $targetFile = $uploadDir . $filename;

        if (!getimagesize($tmpName)) {
            throw new Exception("File $filename is not a valid image.");
        }

        if (!move_uploaded_file($tmpName, $targetFile)) {
            throw new Exception("Failed to upload image: $filename");
        }

        $imagePaths[] = $targetFile;
    }

    $stmt = $connectNow->prepare("INSERT INTO products (
        title, description, price, discount, brand_name, category, rating, subcategory,
        sizes, colors, is_featured, is_new_arrival, is_published, images
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    if (!$stmt) {
        throw new Exception("Failed to prepare the SQL statement: " . $connectNow->error);
    }

    $imagesJson = json_encode($imagePaths);

    $stmt->bind_param(
        'ssddsssissiiis',
        $title,
        $description,
        $price,
        $discount,
        $brand_name,
        $category,
        $rating,
        $subcategory,
        $sizes,
        $colors,
        $is_featured,
        $is_new_arrival,
        $is_published,
        $imagesJson
    );

    if ($stmt->execute()) {
        $response = [
            'success' => true,
            'message' => 'Product uploaded successfully.'
        ];
    } else {
        throw new Exception("Failed to insert product data into database: " . $stmt->error);
    }

    $stmt->close();
    $connectNow->close();

    echo json_encode($response);

} catch (Exception $e) {
    $response = [
        'success' => false,
        'message' => 'Error: ' . $e->getMessage(),
        'debug' => $debug ?? []
    ];
    echo json_encode($response);
}
?>
