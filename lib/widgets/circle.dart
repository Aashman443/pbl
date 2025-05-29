import 'package:flutter/material.dart';
import 'package:zenzo/constants/AppColor.dart';

class Circle extends StatelessWidget {
  const Circle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
    );
  }
}
