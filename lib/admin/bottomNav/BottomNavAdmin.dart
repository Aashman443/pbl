import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zenzo/admin/Home/Admin_home.dart';
import 'package:zenzo/admin/order/order_details_admin.dart';

class BottomNavAdmin extends StatefulWidget {
  const BottomNavAdmin({super.key});

  @override
  State<BottomNavAdmin> createState() => _BottomNavAdminState();
}

class _BottomNavAdminState extends State<BottomNavAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AdminHome(),
    AdminOrdersScreen(),
  ];

  final List<IconData> _icons = [
    CupertinoIcons.house,
    CupertinoIcons.cart,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final bool isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.all(isSelected ? 8 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icons[index],
                  color: isSelected ? Colors.brown : Colors.grey[400],
                  size: isSelected ? 28 : 24,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
