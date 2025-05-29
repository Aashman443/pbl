import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/constants/string.dart';
import 'package:zenzo/user/model/user.dart';
import 'package:zenzo/widgets/Custom_Button.dart';
import 'package:zenzo/widgets/Custom_TextField.dart';
import 'package:http/http.dart' as http;
import '../login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  //  Email Validator
  String? validateEmail(String? value) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password Validator
  String? validatePassword(String? value) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$&*~]).{6,}$');
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Min 6 chars, 1 upper, 1 lower, 1 special char';
    }
    return null;
  }

  Future<void> validateUserEmail() async {
    try {
      var res = await http.post(
        Uri.parse(Api.validateEmail),
        body: {'EMAIL': emailController.text.trim()},
      );

      if (res.statusCode == 200) {
        var resBodyOfEmailValidate = jsonDecode(res.body);
        if (resBodyOfEmailValidate['emailFound'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text("Email is Already Exist!"),
            ),
          );
        } else {
          saveUserRecord();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> saveUserRecord() async {
    User userModel = User(
      userId: 1,
      userName: nameController.text.trim(),
      userEmail: emailController.text.trim(),
      userPassword: passwordController.text.trim(),
    );

    try {
      var res = await http.post(
        Uri.parse(Api.signUp),
        body: userModel.toJson(),
      );
      if (res.statusCode == 200) {
        var resBodyOfSignUp = jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Registration Successful!'),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Registration Failed!'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
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
                    "Create Account",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  Gap(20),
                  Text(
                    AppString.signUpSlogan,
                    style: GoogleFonts.inter(color: AppColors.textGray),
                  ),
                  Gap(80),

                  /// Name
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Gap(10),
                  CustomTextField(
                    maxLine: 1,
                    controller: nameController,
                    prefixIcon: Icon(CupertinoIcons.person),
                    hintText: 'Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  Gap(25),

                  /// Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Gap(10),
                  CustomTextField(
                    controller: emailController,
                    prefixIcon: Icon(CupertinoIcons.mail),
                    hintText: 'example@gmail.com',
                    validator: validateEmail,
                    maxLine: 1,
                  ),
                  Gap(25),

                  /// Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Gap(10),
                  CustomTextField(
                    maxLine: 1,
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icon(CupertinoIcons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                      ),
                    ),
                    hintText: 'Password',
                    validator: validatePassword,
                  ),
                  Gap(50),

                  /// Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: CustomButton(
                      onTaped: () {
                        if (_formKey.currentState!.validate()) {
                          validateUserEmail();
                        }
                      },
                      buttonName: Text(
                        'Sign Up',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Gap(5),

                  /// Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Sign In',
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
                              builder: (context) => LoginScreen(),
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
