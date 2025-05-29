import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenzo/constants/AppColor.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final int? maxLine;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    required this.controller,
    this.validator,
    this.maxLine,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(70),
      borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
    );

    final OutlineInputBorder errorBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(70),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    );

    return TextFormField(
      maxLines: maxLine,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      obscuringCharacter: '#',
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 15,
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textGray),
        fillColor: AppColors.background,
        filled: true,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle,
        errorBorder: errorBorderStyle,
        focusedErrorBorder: errorBorderStyle,
      ),
      validator: validator,
    );
  }
}
