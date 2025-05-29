import 'package:flutter/material.dart';
import 'package:zenzo/admin/bottomNav/BottomNavAdmin.dart';
import 'package:zenzo/constants/theme.dart';
import 'package:zenzo/splashScreen/splash_screen.dart';
import 'package:zenzo/user/features/Cart_Screen/order_sucess_ful.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZenZo',
      theme: AppTheme.zenzoTheme,
      home:  const SplashScreen(),
    );
  }
}
