import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/constants/string.dart';
import 'package:zenzo/user/features/Auth/login/login_screen.dart';
import 'package:zenzo/widgets/Custom_TextField.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isVisible = true;

  void resetPassword() async {
    setState(() => isLoading = true);

    var response = await http.post(
      Uri.parse(Api.forgetPassword),
      body: {'EMAIL': widget.email, 'NEW_PASSWORD': passwordController.text},
    );

    var jsonResponse = json.decode(response.body);
    setState(() => isLoading = false);

    if (jsonResponse['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            'Password reset successful!',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            'Failed to reset password',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Reset Password',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Gap(10),
              Text(
                AppString.resetPassword,
                style: GoogleFonts.inter(color: AppColors.textGray),
                textAlign: TextAlign.center,
              ),
              Gap(80),
              Row(
                children: [
                Text('New Password',style: GoogleFonts.inter(fontSize: 15,fontWeight: FontWeight.w500),)
                ],
              ),
              Gap(5),
              CustomTextField(
                prefixIcon: Icon(
                  CupertinoIcons.lock,
                  color: AppColors.textGray,
                ),
                hintText: 'New Password',
                maxLine: 1,
                controller: passwordController,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon:
                      _isVisible
                          ? Icon(CupertinoIcons.eye_slash)
                          : Icon(CupertinoIcons.eye),
                ),
                obscureText: _isVisible,
              ),
              Gap(40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: isLoading ? null : resetPassword,
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Reset Password',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.background,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
