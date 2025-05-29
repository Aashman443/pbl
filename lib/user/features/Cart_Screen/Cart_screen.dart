import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/user/features/Cart_Screen/order_sucess_ful.dart';
import 'package:zenzo/user/features/user_address/user_address.dart';

import '../../userPrefrences/current_user.dart';
import 'models/cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  String? userEmail;
  List<CartItem> cartItems = [];
  // Add a field to store the selected address
  Address? selectedAddress;
  // Add a field to store the selected payment method
  String selectedPaymentMethod = 'COD (Cash on Delivery)';
  bool isLoading = false;

  Future<void> _loadUserData() async {
    await _currentUser.getUserInfo();
    if (mounted) {
      setState(() {
        userEmail = _currentUser.user?.userEmail;
        print("Loaded User Email in initState: $userEmail");
      });
    }
  }

  Future<void> fetchCartDetails() async {
    final url = Uri.parse(Api.get_cart);
    final String? email = userEmail;

    if (email == null) {
      print('Email is null, cannot fetch cart.');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Product in Cart: ${response.body}');
        if (data['success']) {
          final List<CartItem> loadedItems =
              (data['cart'] as List).map((item) {
                return CartItem(
                  name: item['title'] ?? 'Unknown',
                  size: (item['selected_size'] ?? '').toString(),
                  price:
                      double.tryParse(item['price']?.toString() ?? '0.0') ??
                      0.0,
                  image:
                      item['images'] is String
                          ? item['images']
                          : (item['images']?[0] ?? ''),
                  productId: item['product_id'] ?? 0, // Add product ID
                  color: (item['selected_color'] ?? '').toString(),
                );
              }).toList();

          if (mounted) {
            setState(() {
              cartItems = loadedItems;
            });
          }
        } else {
          print('Error from API: ${data['error']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> removeFromCart(int productId) async {
    print('Removing productId: $productId');
    final url = Uri.parse(Api.remove_cart); // Your PHP endpoint
    final String? email = userEmail;

    if (email == null) {
      print('Email is null, cannot remove item.');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'product_id': productId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('Item removed: ${data['message']}');
          fetchCartDetails(); // Refresh the cart UI
        } else {
          print('API Error: ${data['message'] ?? data['error']}');
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to remove item from cart',
          );
        }
      } else {
        print('Server error: ${response.statusCode}');
        Get.snackbar('Error', 'Server error occurred');
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'An error occurred while removing the item');
    }
  }

  // Add method to fetch user's default address
  Future<void> fetchDefaultAddress() async {
    final String? email = userEmail;
    if (email == null) {
      print('Email is null, cannot fetch default address.');
      return;
    }

    try {
      final uri = Uri.parse('${Api.get_userAddress}?email=$email');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] &&
            data['addresses'] is List &&
            data['addresses'].isNotEmpty) {
          final addr = data['addresses'][0]; // Get the first address
          final defaultAddress = Address(
            id: addr['id'].toString(),
            type: 'Home',
            place:
                '${addr['house_details']}, ${addr['road_details']}, ${addr['city']} - ${addr['pincode']}, ${addr['state']}',
            landmark: 'Alt Phone: ${addr['alternate_phone'] ?? 'N/A'}',
            phoneNumber: addr['phone_number'] ?? '',
            distance: '0 m',
            fullName: addr['full_name'] ?? '',
            alternatePhone: addr['alternate_phone'] ?? '',
            pincode: addr['pincode'] ?? '',
            state: addr['state'] ?? '',
            city: addr['city'] ?? '',
            houseDetails: addr['house_details'] ?? '',
            roadDetails: addr['road_details'] ?? '',
          );

          if (mounted) {
            setState(() {
              selectedAddress = defaultAddress;
            });
          }
        }
      } else {
        print("Error fetching default address: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching default address: $e");
    }
  }

  // Implement the placeOrder function
  Future<bool> placeOrder() async {
    if (selectedAddress == null || userEmail == null) {
      Get.snackbar('Error', 'Please select an address first');
      return false;
    }

    setState(() {
      isLoading = true;
    });

    // Prepare order items
    List<Map<String, dynamic>> orderItems =
        cartItems
            .map(
              (item) => {
                'product_id': item.productId,
                'product_name': item.name,
                'size': item.size,
                'product_image': item.image,
                'color': item.color,
                'price': item.price,
                'quantity': item.quantity,
                'total': item.price * item.quantity,
              },
            )
            .toList();
    print(orderItems);
    // Prepare complete address text
    String addressText =
        '${selectedAddress!.houseDetails}, ${selectedAddress!.roadDetails}, '
        '${selectedAddress!.city} - ${selectedAddress!.pincode}, ${selectedAddress!.state}';

    try {
      final url = Uri.parse(
        Api.order_details,
      ); // Make sure this is defined in your Api class
      final Map<String, dynamic> body = {
        "email": userEmail,
        "full_name": selectedAddress!.fullName,
        "phone_number": selectedAddress!.phoneNumber,
        "alternate_phone": selectedAddress!.alternatePhone,
        "address_type": selectedAddress!.type,
        "address_text": addressText,
        "payment_method": selectedPaymentMethod,
        "subtotal": subtotal,
        "delivery_fee": deliveryFee,
        "total": total,
        "items": orderItems,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"]) {
          print("Order placed successfully");
          // Clear cart after successful order
          // You might want to implement a clearCart() function here
          return true;
        } else {
          print("Failed to place order: ${data['message']}");
          Get.snackbar('Error', data['message'] ?? 'Failed to place order');
          return false;
        }
      } else {
        print("Server Error: ${response.statusCode}");
        Get.snackbar('Error', 'Server error occurred');
        return false;
      }
    } catch (e) {
      print("Exception while placing order: $e");
      Get.snackbar('Error', 'An error occurred while placing the order');
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String promoCode = '';
  double deliveryFee = 40.00;

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get total => subtotal + deliveryFee;

  @override
  void initState() {
    _loadUserData().then((_) {
      fetchCartDetails();
      fetchDefaultAddress(); // Also fetch the default address
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Gap(50),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'My Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      fetchCartDetails();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  cartItems.isEmpty
                      ? const Center(
                        child: Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return CartItemWidget(
                            item: item,
                            onRemove: () {
                              showCupertinoDialog(
                                context: context,
                                builder:
                                    (context) => CupertinoAlertDialog(
                                      title: const Text('Delete'),
                                      content: const Text(
                                        'Are you sure you want to delete?',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('No'),
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                        ),
                                        CupertinoDialogAction(
                                          child: const Text('Yes'),
                                          isDestructiveAction: true,
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await removeFromCart(
                                              item.productId,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                              );
                            },
                            onQuantityChanged: (quantity) {
                              setState(() {
                                item.quantity = quantity;
                              });
                            },
                          );
                        },
                      ),
            ),
            if (cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Promo Code',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  promoCode = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E5C43),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(100, 50),
                          ),
                          onPressed: () {
                            // Apply promo code
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sub-Total',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          '\₹${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Fee',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          '\₹${deliveryFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Cost',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '\₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E5C43),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          _showCheckoutSheet(context);
                        },
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Shipping Address',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedAddress?.type ?? 'Home',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          // Navigate to address screen and wait for result
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => UserAddress(
                                                    selectMode: true,
                                                    currentSelectedAddress:
                                                        selectedAddress,
                                                    onAddressSelected: (
                                                      address,
                                                    ) {
                                                      // This will be called when an address is selected
                                                      if (mounted) {
                                                        this.setState(() {
                                                          selectedAddress =
                                                              address;
                                                        });
                                                      }
                                                    },
                                                  ),
                                            ),
                                          );

                                          // If we got a result back (should be an address), update state
                                          if (result is Address) {
                                            this.setState(() {
                                              selectedAddress = result;
                                            });
                                            // Also update the StatefulBuilder state
                                            setState(() {});
                                          }
                                        },
                                        child: const Text(
                                          'Change',
                                          style: TextStyle(
                                            color: Color(0xFF7E5C43),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedAddress != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedAddress!.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedAddress!.place,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Phone: ${selectedAddress!.phoneNumber}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (selectedAddress!
                                            .alternatePhone
                                            .isNotEmpty)
                                          Text(
                                            'Alt Phone: ${selectedAddress!.alternatePhone}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    )
                                  else
                                    const Text(
                                      'No address selected. Please add an address.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'COD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text('Cash On Delivery'),
                                  ),
                                  const Text(
                                    'Change',
                                    style: TextStyle(
                                      color: Color(0xFF7E5C43),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child:
                                            item.image.isNotEmpty
                                                ? Image.network(
                                                  item.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.image,
                                                    );
                                                  },
                                                )
                                                : const Icon(Icons.image),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'Size: ${item.size}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Color: ${item.color}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Qty: ${item.quantity}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '\₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Sub-Total'),
                                      Text('\₹${subtotal.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Delivery Fee'),
                                      Text(
                                        '\₹${deliveryFee.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\₹${total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7E5C43),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed:
                                    isLoading
                                        ? null
                                        : () async {
                                          if (selectedAddress == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please select an address first',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final success = await placeOrder();
                                          if (success) {
                                            // Clear cart items
                                            setState(() {
                                              cartItems = [];
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        OrderSuccessFull(),
                                              ),
                                            );
                                          }
                                        },
                                child:
                                    isLoading
                                        ? const CircularProgressIndicator.adaptive()
                                        : const Text(
                                          'Place Order',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child:
                item.image.isNotEmpty
                    ? Image.network(
                      item.image,
                      fit: BoxFit.fitHeight,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 40);
                      },
                    )
                    : const Icon(Icons.image, size: 40),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Gap(5),
                Text(
                  'color: ${item.color}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '\₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Row(
            children: [
              // Decrease Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () {
                    if (item.quantity > 1) {
                      onQuantityChanged(item.quantity - 1);
                    }
                  },
                ),
              ),
              // Quantity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.quantity.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Increase Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7E5C43),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  onPressed: () {
                    onQuantityChanged(item.quantity + 1);
                  },
                ),
              ),
            ],
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
