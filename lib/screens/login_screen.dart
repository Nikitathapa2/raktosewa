import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/screens/hive_screen.dart';
import 'package:raktosewa/screens/register_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String userType = "donor";
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {
    if (userType == "donor") {
      // Call donor login from DonorViewModel
      await ref
          .read(donorViewModelProvider.notifier)
          .loginDonor(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

      final state = ref.read(donorViewModelProvider);
      if (state.status == AuthStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login Successful")));
        // Navigate to Hive screen or Dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DonorHiveScreen()),
        );
      } else if (state.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? "Login Failed")),
        );
      }
    } else {
      // TODO: Implement organization login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Organization login not implemented yet")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorState = ref.read(donorViewModelProvider);

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Top logo section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: screenWidth * 0.55,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "RaktoSewa",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom login card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Container(
                        width: screenWidth * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            // Donor / Organization tabs
                            Row(
                              children: [
                                _userTypeTab("donor", "Donor"),
                                _userTypeTab("organization", "Organization"),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Email & Password
                            _inputField(
                              "Email",
                              emailController,
                              keyboard: TextInputType.emailAddress,
                            ),
                            _passwordField("Password", passwordController),

                            const SizedBox(height: 20),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    donorState.status == AuthStatus.loading
                                    ? null
                                    : _login,
                                child: donorState.status == AuthStatus.loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Login"),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Links
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DonorRegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Don't have an account? Register",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DonorHiveScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Hive db",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userTypeTab(String type, String label) {
    final bool isActive = userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => userType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.red : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => showPassword = !showPassword),
          ),
        ),
      ),
    );
  }
}
