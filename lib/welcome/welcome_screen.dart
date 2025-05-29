import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/constants/string.dart';
import 'package:zenzo/widgets/Custom_Button.dart';
import 'package:zenzo/widgets/circle.dart';

import '../user/features/Auth/Sign Up/signUp_screen.dart';
import '../user/features/Auth/login/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.4,
                height: height * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome3.jpg'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Gap(10),
              Column(
                children: [
                  Container(
                    width: width * 0.38,
                    height: height * 0.23,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      image: DecorationImage(
                        image: AssetImage('assets/images/welcome1.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Gap(10),
                  Container(
                    width: width * 0.32,
                    height: height * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      image: DecorationImage(
                        image: AssetImage('assets/images/welcome2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Gap(30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                ' Zenzo App',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' That',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          Text(
            AppString.welcome,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          Gap(50),
          Text(
            AppString.slogan,
            style: GoogleFonts.inter(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
          Gap(40),

          /// button for the SignUp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              onTaped: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen(),));
              },
              buttonName: Text(
                'Sign Up',
                style: GoogleFonts.inter(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppString.accountAlready,
                style: GoogleFonts.inter(fontSize: 15),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
