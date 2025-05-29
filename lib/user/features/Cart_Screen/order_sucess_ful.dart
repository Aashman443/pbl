import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/user/features/BottomNav/bottom_nav.dart';
import 'package:zenzo/widgets/Custom_Button.dart';

class OrderSuccessFull extends StatefulWidget {
  const OrderSuccessFull({super.key});

  @override
  State<OrderSuccessFull> createState() => _OrderSuccessFullState();
}

class _OrderSuccessFullState extends State<OrderSuccessFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Lottie.asset('assets/animations/order_success.json')),

          Gap(300),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: CustomButton(
              onTaped: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNav()),
                );

              },
              buttonName: Text(
                'Back to Home',
                style: GoogleFonts.inter(
                  color: AppColors.background,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
