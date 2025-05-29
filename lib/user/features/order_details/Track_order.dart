// track_order.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zenzo/api_connection/api_connection.dart';
import '../../userPrefrences/current_user.dart';
import 'order_details.dart'; // For navigating to order details

// Remove duplicate OrderItem class - use the one from MyOrdersScreen.dart

class TrackingStatus {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isCancelled;

  TrackingStatus({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    this.isCancelled = false,
  });
}

class TrackOrderScreen extends StatefulWidget {
  final OrderItem order;

  const TrackOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  _TrackOrderScreenState createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  List<TrackingStatus> trackingStatuses = [];
  bool isLoading = true;
  bool isCancelling = false;
  late OrderItem currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
    _fetchOrderStatus();
  }

  // Fetch order status from API
  Future<void> _fetchOrderStatus() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse("${Api.get_order}?order_id=${currentOrder.id}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update current order with latest status
          setState(() {
            currentOrder = OrderItem(
              id: currentOrder.id,
              name: currentOrder.name,
              price: currentOrder.price,
              size: currentOrder.size,
              color: currentOrder.color,
              quantity: currentOrder.quantity,
              imageUrl: currentOrder.imageUrl,
              status: responseData['data']['status'] ?? currentOrder.status,
              createdAt: currentOrder.createdAt,
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching order status: $e");
    } finally {
      _generateTrackingStatuses();
      setState(() {
        isLoading = false;
      });
    }
  }

  // Cancel order API call
  Future<void> _cancelOrder() async {
    try {
      setState(() {
        isCancelling = true;
      });

      final response = await http.post(
        Uri.parse(Api.cancel_order),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': currentOrder.id,
          'user_id': _currentUser.user?.userEmail ?? '',
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update order status to cancelled
          setState(() {
            currentOrder = OrderItem(
              id: currentOrder.id,
              name: currentOrder.name,
              price: currentOrder.price,
              size: currentOrder.size,
              color: currentOrder.color,
              quantity: currentOrder.quantity,
              imageUrl: currentOrder.imageUrl,
              status: 'cancelled',
              createdAt: currentOrder.createdAt,
            );
          });

          _generateTrackingStatuses();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to cancel order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error cancelling order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred while cancelling order'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isCancelling = false;
      });
    }
  }

  // Show cancel confirmation dialog
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelOrder();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _generateTrackingStatuses() {
    String currentStatus = currentOrder.status.toLowerCase();
    DateTime orderDate;
    try {
      orderDate = DateTime.parse(currentOrder.createdAt);
    } catch (e) {
      orderDate = DateTime.now().subtract(Duration(days: 2));
    }

    if (currentStatus == 'cancelled') {
      trackingStatuses = [
        TrackingStatus(
          title: 'Order Placed',
          subtitle: _formatDateTime(orderDate),
          icon: Icons.description_outlined,
          isCompleted: true,
        ),
        TrackingStatus(
          title: 'Cancelled',
          subtitle: _formatDateTime(orderDate.add(Duration(hours: 1))),
          icon: Icons.cancel_outlined,
          isCompleted: true,
          isCancelled: true,
        ),
      ];
    } else {
      trackingStatuses = [
        TrackingStatus(
          title: 'Order Placed',
          subtitle: _formatDateTime(orderDate),
          icon: Icons.description_outlined,
          isCompleted: true,
        ),
        TrackingStatus(
          title: 'In Progress',
          subtitle: _formatDateTime(orderDate.add(Duration(hours: 2))),
          icon: Icons.inventory_2_outlined,
          isCompleted: currentStatus == 'active' || currentStatus == 'completed',
        ),
        TrackingStatus(
          title: 'Shipped',
          subtitle:
          currentStatus == 'completed'
              ? _formatDateTime(orderDate.add(Duration(days: 1)))
              : 'Expected ${_formatDate(orderDate.add(Duration(days: 2)))}',
          icon: Icons.local_shipping_outlined,
          isCompleted: currentStatus == 'completed',
        ),
        TrackingStatus(
          title: 'Delivered',
          subtitle:
          currentStatus == 'completed'
              ? _formatDateTime(orderDate.add(Duration(days: 3)))
              : 'Expected ${_formatDate(orderDate.add(Duration(days: 7)))}',
          icon: Icons.inventory_2_outlined,
          isCompleted: currentStatus == 'completed',
        ),
      ];
    }
  }

  String _formatDateTime(DateTime dateTime) {
    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour12 = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)} ${dateTime.year}, ${hour12.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)} ${dateTime.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchOrderStatus,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back and Title
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Track Order',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _fetchOrderStatus,
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
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Product Card
                _buildProductCard(),

                const SizedBox(height: 30),

                // Order Details
                _buildOrderDetails(),

                const SizedBox(height: 30),

                // Tracking Timeline
                _buildOrderStatus(),

                const SizedBox(height: 20),

                // Cancel Order Button (only show if order can be cancelled)
                if (_canCancelOrder()) _buildCancelButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canCancelOrder() {
    String status = currentOrder.status.toLowerCase();
    return status != 'cancelled' && status != 'completed' && status != 'shipped';
  }

  Widget _buildCancelButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isCancelling ? null : _showCancelDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isCancelling
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Cancel Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFD2B48C),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: currentOrder.imageUrl.isNotEmpty
                  ? Image.network(
                currentOrder.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.brown[300],
                    size: 40,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) =>
                loadingProgress == null
                    ? child
                    : Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : Center(
                child: Icon(
                  Icons.checkroom,
                  color: Colors.brown[300],
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentOrder.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${currentOrder.size} | Qty: ${currentOrder.quantity}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (currentOrder.color.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Color: ${currentOrder.color}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '₹${currentOrder.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Order ID', currentOrder.id),
          _buildDetailRow('Order Date', _formatDate(DateTime.tryParse(currentOrder.createdAt) ?? DateTime.now())),
          _buildDetailRow(
            'Status',
            currentOrder.status.toUpperCase(),
            statusColor: _getStatusColor(currentOrder.status),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
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

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...trackingStatuses.asMap().entries.map((entry) {
            int index = entry.key;
            TrackingStatus status = entry.value;
            bool isLast = index == trackingStatuses.length - 1;

            return _buildStatusItem(status, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusItem(TrackingStatus status, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                status.isCompleted
                    ? (status.isCancelled
                    ? Colors.red
                    : const Color(0xFF8B4513))
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                status.isCompleted ? Icons.check : status.icon,
                color: status.isCompleted ? Colors.white : Colors.grey[600],
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color:
                status.isCompleted
                    ? (status.isCancelled
                    ? Colors.red
                    : const Color(0xFF8B4513))
                    : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                  status.isCompleted
                      ? (status.isCancelled ? Colors.red : Colors.black)
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}