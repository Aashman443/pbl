import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zenzo/user/features/Cart_Screen/Cart_screen.dart';
import 'package:zenzo/user/features/Favorite_Screen/favorite_screen.dart';
import 'package:zenzo/user/features/HomeScreen/Home_screen.dart';
import 'package:zenzo/user/features/Profile_Screen/profile_screen.dart';
import 'package:zenzo/user/userPrefrences/current_user.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectedIndex = 0;
  final CurrentUser _rememberCurrentUser = Get.put(CurrentUser());

  final List<IconData> icons = [
    CupertinoIcons.house,
    CupertinoIcons.cart,
    Icons.favorite_border,
    CupertinoIcons.person,
  ];

  final List<Widget> _pages =[
    HomeScreen(),
    CartScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CurrentUser(),
      initState: (currentState){
        _rememberCurrentUser.getUserInfo();
      },
      builder: (controller) => Scaffold(
      backgroundColor:Colors.white,
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icons.length, (index) {
            bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.all(isSelected ? 8 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[index],
                  color: isSelected ? Colors.brown : Colors.grey[400],
                  size: isSelected ? 28 : 24,
                ),
              ),
            );
          }),
        ),
      ),
      body: _pages[selectedIndex],
    ),);
  }
}