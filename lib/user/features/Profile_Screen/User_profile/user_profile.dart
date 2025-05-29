import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/widgets/Custom_Button.dart';
import 'package:zenzo/widgets/Custom_TextField.dart';
import '../../../../api_connection/api_connection.dart';
import '../../../userPrefrences/current_user.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController resetPasswordController = TextEditingController();
  final CurrentUser _currentUser = Get.put(CurrentUser());
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser.getUserInfo();
  }

  @override
  void dispose() {
    resetPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final newPassword = resetPasswordController.text.trim();
    final email = _currentUser.user?.userEmail;

    if (newPassword.isEmpty) {
      Get.snackbar('Error', 'Please enter a new password');
      return;
    }

    if (email == null || email.isEmpty) {
      Get.snackbar('Error', 'User email is missing');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Api.forgetPassword),
        body: {
          'EMAIL': email,
          'NEW_PASSWORD': newPassword,
        },
      );

      final jsonResponse = json.decode(response.body);
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
        resetPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              jsonResponse['message'] ?? 'Failed to reset password',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Widget profileInfoBox(String value) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColors.background,
        border: Border.all(color: AppColors.textGray, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final user = _currentUser.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(30),
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://static-00.iconduck.com/assets.00/person-icon-256x242-au2z2ine.png',
                    ),
                  ),
                ),
                const Gap(30),

                Gap(20),
                buildLabel('Name'),
                const Gap(5),
                profileInfoBox(user.userName ?? "Not available"),

                const Gap(20),
                buildLabel('Email'),
                const Gap(5),
                profileInfoBox(user.userEmail ?? "Not available"),

                const Gap(20),
                buildLabel('Reset Password'),
                const Gap(5),
                CustomTextField(
                  hintText: 'Enter new password',
                  controller: resetPasswordController,
                ),

                const Gap(30),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                  onTaped: resetPassword,
                  buttonName: Text(
                    'Reset Password',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
