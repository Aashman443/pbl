import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Api.get_Order_Admin; // Replace with your actual API endpoint
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data['orders'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load orders")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> updateOrderStatus(int id, String newStatus) async {
    try {
      final url = Api.update_order_status; // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"id": id, "status": newStatus}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Order #$id status updated to '$newStatus'"),
            backgroundColor: Colors.green,
          ));
          fetchOrders(); // Refresh the orders list after update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to update status"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Server error, try again"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text('No orders found'))
          : RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            int orderId;
            try {
              orderId = order['id'] is int
                  ? order['id']
                  : int.parse(order['id'].toString());
            } catch (e) {
              orderId = 0; // fallback id if conversion fails
            }

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin:
              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: $orderId',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Customer & email info with icons
                    Row(
                      children: [
                        Icon(Icons.person,
                            color: Colors.grey[600], size: 20),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                              'Customer: ${order['full_name'] ?? ''}'),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.email,
                            color: Colors.grey[600], size: 20),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                              'Email: ${order['email'] ?? ''}'),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    // Total amount
                    Row(
                      children: [
                        Icon(Icons.currency_rupee,
                            color: Colors.green[700], size: 20),
                        SizedBox(width: 5),
                        Text(
                          'Total: ₹${order['total'] ?? 0}',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    Divider(height: 25, thickness: 1),

                    // Status update row
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Update Status:',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        DropdownButton<String>(
                          value: order['status'] ?? 'pending',
                          style: TextStyle(
                              color: Colors.black, fontSize: 16),
                          items: [
                            'pending',
                            'processing',
                            'shipped',
                            'delivered',
                            'cancelled'
                          ].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status[0].toUpperCase() +
                                    status.substring(1),
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null &&
                                newStatus != order['status']) {
                              updateOrderStatus(orderId, newStatus);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
