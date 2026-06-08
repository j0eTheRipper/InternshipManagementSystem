import 'package:flutter/material.dart';
import 'package:internship_management_system/login_screen/system_feature.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "internship management system",
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: 48,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        SystemFeature(
          mainText: 'Curated opportunities',
          subText: 'Companies matched to your field of study',
        ),
        SystemFeature(
          mainText: 'Easy communication',
          subText: 'Easily communicate with your mentor and supervisor',
        ),
        SystemFeature(
          mainText: 'Progress tracking',
          subText: 'See your progress in the internship.',
        ),
      ],
    );
  }
}
