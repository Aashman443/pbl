import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenzo/admin/login/admin_login.dart';
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/constants/string.dart';
import 'package:zenzo/user/features/Auth/forget_password/forget_password.dart';
import 'package:zenzo/user/features/BottomNav/bottom_nav.dart';
import 'package:zenzo/user/model/user.dart';
import 'package:zenzo/user/userPrefrences/user_prefrences.dart';
import 'package:zenzo/widgets/Custom_Button.dart';
import 'package:zenzo/widgets/Custom_TextField.dart';
import 'package:http/http.dart' as http;

import '../Sign Up/signUp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isVisible = true;


  Future<void> loginUserNow() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Please enter both email and password.'),
        ),
      );
      return;
    }

    try {
      final res = await http.post(
        Uri.parse(Api.login),
        body: {
          'user_email': email,
          'user_password': password,
        },
      );

      print('Raw response body: ${res.body}'); // Debugging

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        try {
          final resBodyOfLogin = jsonDecode(res.body);
          print('Decoded login response: $resBodyOfLogin');

          if (resBodyOfLogin['success'] == true &&
              resBodyOfLogin['user_email'] != null) {
            Fluttertoast.showToast(
              msg: 'Login Successful!',
              backgroundColor: AppColors.primary,
            );

            // Construct user object
            User userInfo = User(
              userName: resBodyOfLogin['user_name'],
              userEmail: resBodyOfLogin['user_email'],
              // Add more fields if needed
            );

            // Save to shared preferences
            await RememberUserPref.saveUserInfo(userInfo);
            print('User saved in shared preferences');

            // Navigate to main screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNav()),
            );
          } else {
            print('Login failed or user data missing');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primary,
                content:
                Text(resBodyOfLogin['error'] ?? 'Invalid credentials.'),
              ),
            );
          }
        } catch (e) {
          print('Failed to decode JSON: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Invalid server response format.'),
            ),
          );
        }
      } else {
        print('Server error or empty response');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Server error. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }




  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                children: [
                  Gap(60),
                  Text(
                    "Sign In",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  Gap(20),
                  Text(
                    AppString.loginSlogan,
                    style: GoogleFonts.inter(color: AppColors.textGray),
                  ),
                  Gap(80),

                  /// for the  email TextField
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Email',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(10),
                  CustomTextField(
                    controller:  emailController,
                    prefixIcon: Icon(CupertinoIcons.mail),
                    hintText: 'example@gmail.com',
                    maxLine: 1,
                  ),
                  Gap(25),

                  /// for the password text field
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(10),
                  CustomTextField(
                    controller: passwordController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: _isVisible?Icon(CupertinoIcons.eye_slash):Icon(CupertinoIcons.eye),
                    ),
                    obscureText: _isVisible,
                    prefixIcon: Icon(CupertinoIcons.lock),
                    hintText: 'Password',
                    maxLine: 1,
                  ),

                  /// for the forget password button
                  Align(
                    alignment: Alignment.topRight,
                    child: CupertinoButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),));
                      },
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Forget Password?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  Gap(40),

                  /// for the login button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: CustomButton(
                      onTaped: () {
                        if(_formKey.currentState!.validate()){
                          loginUserNow();
                        }
                      },
                      buttonName: Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Gap(5),

                  /// for the  SignUp Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have account?',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Text('or',style: GoogleFonts.inter(fontSize: 16),),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Are you Admin?',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Click Here',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Admin_LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}