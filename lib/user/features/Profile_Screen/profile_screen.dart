import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zenzo/user/features/Auth/login/login_screen.dart';
import 'package:zenzo/user/features/Profile_Screen/User_profile/user_profile.dart';
import 'package:zenzo/user/features/order_details/order_details.dart';
import 'package:zenzo/user/features/user_address/user_address.dart';
import 'package:zenzo/user/userPrefrences/current_user.dart';
import 'package:zenzo/user/userPrefrences/user_prefrences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());

  @override
  void initState() {
    super.initState();
    _currentUser.getUserInfo(); // Fetch user info when screen loads
  }

  Future<void> logout() async {
    // Server logout (optional)
    try {
      await http.post(Uri.parse('http://localhost:8888/zenzo/user/logout.php'));
    } catch (e) {
      print('Logout error: $e');
    }

    // Local logout
    await RememberUserPref.removeUserInfo();
    _currentUser.removeUser();

    // Navigate to login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Obx(() {
        final user = _currentUser.user;
        if (user == null) {
          return const SizedBox(); // Avoid CircularProgressIndicator
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://static-00.iconduck.com/assets.00/person-icon-256x242-au2z2ine.png',
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                user.userName ?? 'Guest',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              profileMenuItem(Icons.person_outline, 'Your profile'),
              profileMenuItem(Icons.location_on_outlined, 'Your Address'),
              profileMenuItem(Icons.payment_outlined, 'Payment Methods'),
              profileMenuItem(Icons.shopping_bag_outlined, 'My Orders'),
              profileMenuItem(Icons.settings_outlined, 'Settings'),
              profileMenuItem(Icons.help_outline, 'Help Center'),
              profileMenuItem(Icons.lock_outline, 'Privacy Policy'),
              profileMenuItem(Icons.person_add_outlined, 'Invite Friends'),
              profileMenuItem(Icons.logout, 'Log out'),
            ],
          ),
        );
      }),
    );
  }

  Widget profileMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (title == 'Log out') {
          showCupertinoDialog(
            context: context,
            builder:
                (_) => CupertinoAlertDialog(
                  title: Text('Log out'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('No'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      child: Text('Yes'),
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        logout();
                      },
                    ),
                  ],
                ),
          ); // Just logout directly
        } else if (title == 'Your profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfile()),
          );
        } else if (title == 'Your Address') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserAddress()),
          );
        } else if (title == 'My Orders') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyOrdersScreen()),
          );
        } else {
          Get.snackbar("Navigation", "Tapped on $title");
        }
      },
    );
  }
}
