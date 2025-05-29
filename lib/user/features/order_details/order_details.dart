// MyOrdersScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/user/features/order_details/Track_order.dart';
import '../../userPrefrences/current_user.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  String? userEmail;
  int selectedTabIndex = 0;
  final List<String> tabs = ['Active', 'Completed', 'Cancelled'];
  List<OrderItem> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchOrders();
  }

  Future<void> _loadUserDataAndFetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Load user data
      await _currentUser.getUserInfo();
      userEmail = _currentUser.user?.userEmail;

      debugPrint("=== DEBUG INFO ===");
      debugPrint("Current user: ${_currentUser.user}");
      debugPrint("User email: $userEmail");

      if (userEmail != null && userEmail!.isNotEmpty) {
        await fetchOrders(userEmail!);
      } else {
        setState(() {
          errorMessage = "User email not found. Please login again.";
          isLoading = false;
        });
        debugPrint("ERROR: User email is null or empty");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user data: $e";
        isLoading = false;
      });
      debugPrint("ERROR loading user data: $e");
    }
  }

  Future<void> fetchOrders(String email) async {
    final String apiUrl = Api.get_order;

    try {
      debugPrint("=== API CALL DEBUG ===");
      debugPrint("API URL: $apiUrl");
      debugPrint("Email being sent: $email");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Parsed Data: $data");

        if (data["success"] == true) {
          if (data["orders"] != null && data["orders"] is List) {
            List<dynamic> ordersData = data["orders"];
            debugPrint("Orders count: ${ordersData.length}");

            setState(() {
              orders = ordersData.map((order) {
                debugPrint("Processing order: $order");
                return OrderItem.fromJson(order);
              }).toList();
              isLoading = false;
              errorMessage = '';
            });

            debugPrint("Successfully loaded ${orders.length} orders");
          } else {
            setState(() {
              orders = [];
              isLoading = false;
              errorMessage = data["message"] ?? "No orders found";
            });
            debugPrint("No orders found in response");
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data["message"] ?? "Failed to fetch orders";
          });
          debugPrint("API returned success: false - ${data["message"]}");
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}";
        });
        debugPrint("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Network error: $e";
      });
      debugPrint("ERROR fetching orders: $e");
    }
  }

  List<OrderItem> get filteredOrders {
    if (orders.isEmpty) return [];

    String filterStatus = tabs[selectedTabIndex].toLowerCase();
    debugPrint("Filtering orders by status: $filterStatus");

    List<OrderItem> filtered = orders.where((order) {
      bool matches = order.status.toLowerCase() == filterStatus;
      debugPrint("Order ${order.id} status: ${order.status.toLowerCase()}, matches: $matches");
      return matches;
    }).toList();

    debugPrint("Filtered orders count: ${filtered.length}");
    return filtered;
  }

  Future<void> _refreshOrders() async {
    if (userEmail != null && userEmail!.isNotEmpty) {
      await fetchOrders(userEmail!);
    } else {
      await _loadUserDataAndFetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'My Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Debug Info (Remove in production)
            if (errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Show total orders count for debugging
            if (orders.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Total Orders: ${orders.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tab = entry.value;
                  bool isSelected = selectedTabIndex == index;

                  // Count orders for each tab
                  int tabCount = orders.where((order) =>
                  order.status.toLowerCase() == tab.toLowerCase()).length;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? const Color(0xFF8B4513) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              tab,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? const Color(0xFF8B4513) : Colors.grey,
                              ),
                            ),
                            if (tabCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF8B4513) : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$tabCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Orders List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshOrders,
                child: isLoading
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading orders...'),
                    ],
                  ),
                )
                    : orders.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage.isNotEmpty ? errorMessage : "No orders found",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
                    : filteredOrders.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No ${tabs[selectedTabIndex].toLowerCase()} orders found",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Switch to other tabs to see your orders",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return OrderCard(order: filteredOrders[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: order.imageUrl.isNotEmpty
                  ? Image.network(
                order.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 30, color: Colors.brown),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              )
                  : const Icon(Icons.image, size: 30, color: Colors.brown),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Size: ${order.size} | Qty: ${order.quantity}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                if (order.color.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Color: ${order.color}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
                const SizedBox(height: 4),
                // Show order status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('\$${order.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // FIXED: Pass the complete OrderItem object instead of just the ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackOrderScreen(order: order),  // Changed from order.id to order
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Track Order',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class OrderItem {
  final dynamic id;
  final String name;
  final String size;
  final String quantity;
  final String price;
  final String imageUrl;
  final String status;
  final String color;
  final String createdAt;

  OrderItem({
    required this.id,
    required this.name,
    required this.size,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.color,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    debugPrint("Creating OrderItem from JSON: $json");
    return OrderItem(
      id: json['id']?.toString() ?? '',
      name: json['product_name'] ?? json['name'] ?? 'Unknown Product',
      size: json['size']?.toString() ?? 'N/A',
      quantity: json['quantity']?.toString() ?? '0',
      price: json['price']?.toString() ?? '0',
      imageUrl: json['product_image'] ?? json['image'] ?? '',
      status: json['status']?.toString() ?? 'active',
      color: json['color']?.toString() ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  // Helper method to generate tracking ID based on order ID
  String get trackingId => 'TRK${id.toString().padLeft(9, '0')}';

  // Helper method to get expected delivery date (7 days from order creation)
  String get expectedDeliveryDate {
    try {
      DateTime orderDate = DateTime.parse(createdAt);
      DateTime deliveryDate = orderDate.add(Duration(days: 7));
      return '${deliveryDate.day.toString().padLeft(2, '0')} ${_getMonthName(deliveryDate.month)} ${deliveryDate.year}';
    } catch (e) {
      return '07 days from order';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Helper method to format order date
  String get formattedOrderDate {
    try {
      DateTime orderDate = DateTime.parse(createdAt);
      return '${orderDate.day.toString().padLeft(2, '0')} ${_getMonthName(orderDate.month)} ${orderDate.year}, ${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')} ${orderDate.hour >= 12 ? 'PM' : 'AM'}';
    } catch (e) {
      return createdAt;
    }
  }
}