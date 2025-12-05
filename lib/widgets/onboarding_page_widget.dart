import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: screenWidth,
            height: screenHeight * 0.4,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
