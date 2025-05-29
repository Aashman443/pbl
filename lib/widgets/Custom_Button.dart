import 'package:flutter/material.dart';
import 'package:zenzo/constants/AppColor.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTaped;
  final Widget buttonName;
  const CustomButton({
    super.key,
    required this.onTaped,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary
          ),
            onPressed: onTaped, child: buttonName));
  }
}
