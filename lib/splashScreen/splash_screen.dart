import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/widgets/circle.dart';
import '../user/features/BottomNav/bottom_nav.dart';
import '../user/userPrefrences/user_prefrences.dart';
import '../welcome/welcome_screen.dart';
import '../user/model/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // Define scale animation for the logo transition
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Check if the user is logged in after a 3-second delay
    Timer(const Duration(seconds: 3), checkIfUserIsLoggedIn);
  }

  Future<void> checkIfUserIsLoggedIn() async {
    User? currentUser = await RememberUserPref.readUserInfo();

    // If the user is logged in, navigate to the BottomNav screen
    if (currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BottomNav()),
      );
    } else {
      // If the user is not logged in, navigate to the WelcomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      'Z',
                      style: GoogleFonts.pacifico(
                        fontSize: 40,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Zenzo',
                    style: GoogleFonts.pacifico(
                      fontSize: 35,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '.',
                    style: GoogleFonts.pacifico(
                      fontSize: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned circles
          Positioned(
            left: 290,
            bottom: 800,
            child: SizedBox(width: 200, height: 200, child: const Circle()),
          ),
          Positioned(
            top: 680,
            right: 220,
            child: SizedBox(width: 300, height: 300, child: const Circle()),
          ),
        ],
      ),
    );
  }
}