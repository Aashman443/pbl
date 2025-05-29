import 'dart:convert';
import 'dart:io';

class Api {
  static String hostConnect =
      Platform.isAndroid
          ? 'http://10.0.2.2:8888/zenzo/user'
          : 'http://localhost:8888/zenzo/user';

  // Endpoint for signing up the user
  static String signUp = "$hostConnect/signUp.php";

  // Endpoint for validating email
  static String validateEmail =
      "$hostConnect/validate_email.php";

  //Endpoint for the  login
  static String login = "$hostConnect/login.php";

  // for the forget password

  static String forgetPassword =
      "$hostConnect/forget_password.php";

  // for the admin api

  static String baseUrl =
      Platform.isAndroid
          ? 'http://10.0.2.2:8888/zenzo/Admin'
          : 'http://localhost:8888/zenzo/Admin';

  static String loginUrl = '$baseUrl/login.php';


  // for the product_upload
static String upload_product = '$baseUrl/upload_product.php';

// fetch the product

static String get_Productdata = '$hostConnect/get_products.php';

// for upload add_cart

static String add_cart ='$hostConnect/cart/add_to_cart.php';

// fetch cart_details
static String get_cart = '$hostConnect/cart/get_cart.php';

// remove item form cart
static String remove_cart ='$hostConnect/cart/remove_cart.php';

// adding data into favorite_Screen
static String add_favorite = "$hostConnect/favorite/add_favorite.php";

// for get the favorite data
static String get_favorite = '$hostConnect/favorite/get_favorite.php';

// for delete the favorite
static String remove_favorite = '$hostConnect/favorite/remove_favorite.php';

// for save user_address
static String add_userAddress = '$hostConnect/user_address/user_address.php';

// for gat the user_address
static String get_userAddress = '$hostConnect/user_address/get_userAddress.php';

// update the userAddress
static String update_userAddress = '$hostConnect/user_address/update_userAddress.php';

// for place order
static String order_details = '$hostConnect/order/order.php';

// for geting the order details
static String get_order = '$hostConnect/order/get_order.php';

// for get the order details for admin
static String get_Order_Admin = '$baseUrl/order/get_order_admin.php';

// for the update the order status admin
static String update_order_status = '$baseUrl/order/order_status.php';

// for geting order status
static String get_order_status = '$hostConnect/order/get_order_status.php';

// for cancel order
static String cancel_order  ='$hostConnect/order/cancel_order.php';
}

// http://10.0.2.2:8888/zenzo/Admin
