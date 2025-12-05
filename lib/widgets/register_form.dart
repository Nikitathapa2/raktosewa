import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(decoration: InputDecoration(hintText: "Full Name")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Gender")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Date of Birth")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Blood Group")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Province")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "District")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Local Level")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Ward No")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Email")),
        const SizedBox(height: 12),

        const TextField(decoration: InputDecoration(hintText: "Phone Number")),
        const SizedBox(height: 12),

        TextField(
          obscureText: obscurePassword,
          decoration: InputDecoration(
            hintText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          obscureText: obscureConfirm,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscureConfirm = !obscureConfirm;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Register",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
