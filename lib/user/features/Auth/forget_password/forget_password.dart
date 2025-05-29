import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zenzo/user/features/Auth/forget_password/reset_password.dart';
import 'package:zenzo/widgets/Custom_Button.dart';
import 'package:zenzo/widgets/Custom_TextField.dart';

import '../../../../api_connection/api_connection.dart';
import '../../../../constants/AppColor.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> validateUserEmail() async {
    try {
      var res = await http.post(
        Uri.parse(Api.validateEmail),
        body: {'EMAIL': emailController.text.trim()},
      );

      if (res.statusCode == 200) {
        var resBodyOfEmailValidate = jsonDecode(res.body);
        if (resBodyOfEmailValidate['emailFound'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordScreen(email: emailController.text.trim()),
            ),
          );
        } else {
          // Show SnackBar if email not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Email is not found'),
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
    emailController.dispose();
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
                'Confirm it\'s you.',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We just need to verify your email\n to help you continue.',
                style: GoogleFonts.inter(color: AppColors.textGray),
                textAlign: TextAlign.center,
              ),
              Gap(100),
              Row(
                children: [
                Text('Email',style: GoogleFonts.inter(fontSize: 16,),)
                ],
              ),
              Gap(5),
              CustomTextField(
                prefixIcon: Icon(
                  CupertinoIcons.mail,
                  color: AppColors.textGray,
                ),
                hintText: 'Email',
                controller: emailController,
              ),
              Gap(40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: isLoading ? null : validateUserEmail,
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            color: AppColors.background,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
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
