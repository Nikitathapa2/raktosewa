import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/utils/snackbar_utils.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/screens/hive_screen.dart';
import 'package:raktosewa/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:raktosewa/features/auth/presentation/pages/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String userType = "donor";
  bool showPassword = false;
  bool _isSubmitting = false;
  DateTime? _lastSubmit;
  static const _submitCooldown = Duration(seconds: 2);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {
    final now = DateTime.now();
    if (_isSubmitting) return; // Prevent rapid repeat taps while in-flight
    if (_lastSubmit != null && now.difference(_lastSubmit!) < _submitCooldown) {
      SnackbarUtils.showWarning(context, "Please wait a moment before retrying");
      return;
    }
    setState(() => _isSubmitting = true);

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackbarUtils.showWarning(context, "Please fill in all fields");
      setState(() => _isSubmitting = false);
      return;
    }

    try {
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
          SnackbarUtils.showSuccess(context, "Login Successful");
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        } else if (state.status == AuthStatus.error) {
          SnackbarUtils.showError(context, state.errorMessage ?? "Login Failed");
        }
      } else if (userType == "organization") {
        // Call organization login from OrganizationViewModel
        await ref
            .read(organizationViewModelProvider.notifier)
            .loginOrganization(
              emailController.text.trim(),
              passwordController.text.trim(),
            );

        final state = ref.read(organizationViewModelProvider);
        if (state.status == AuthStatus.success) {
          SnackbarUtils.showSuccess(context, "Login Successful");
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        } else if (state.status == AuthStatus.error) {
          SnackbarUtils.showError(context, state.errorMessage ?? "Login Failed");
        }
      }
    } finally {
      _lastSubmit = now;
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorState = ref.watch(donorViewModelProvider);
    final organizationState = ref.watch(organizationViewModelProvider);
    final isLoading = _isSubmitting ||
      (userType == "donor"
        ? donorState.status == AuthStatus.loading
        : organizationState.status == AuthStatus.loading);

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
                                onPressed: isLoading ? null : _login,
                                child: isLoading
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
