import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(Icons.home, color: Colors.red, size: 30),
          Icon(Icons.bloodtype, color: Colors.grey, size: 30),
          Icon(Icons.notifications, color: Colors.grey, size: 30),
          Icon(Icons.person, color: Colors.grey, size: 30),
        ],
      ),
    );
  }
}
