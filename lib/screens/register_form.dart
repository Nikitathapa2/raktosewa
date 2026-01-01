import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/screens/hive_screen.dart';
import 'package:raktosewa/widgets/primary_button.dart';

class DonorRegisterScreen extends ConsumerStatefulWidget {
  const DonorRegisterScreen({super.key});

  @override
  ConsumerState<DonorRegisterScreen> createState() =>
      _DonorRegisterScreenState();
}

class _DonorRegisterScreenState extends ConsumerState<DonorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String userType = "donor";
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool termsAccepted = false;
  bool _isLoading = false;

  // Controllers
  final fullNameController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    bloodGroupController.dispose();
    dobController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to DonorState changes
    ref.listen<DonorState>(donorViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login Successful")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DonorHiveScreen()),
        );
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Register to Raktosewa")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _userTypeSwitch(),
              const SizedBox(height: 20),

              if (userType == "donor") ...[
                _inputField("Full Name", fullNameController),
                _dropdownBloodGroup(),
                _datePicker(),
              ],

              _inputField(
                "Email",
                emailController,
                keyboard: TextInputType.emailAddress,
              ),
              _inputField(
                "Phone Number",
                phoneController,
                keyboard: TextInputType.phone,
              ),
              _inputField("Address", addressController),
              _passwordField(
                "Password",
                passwordController,
                showPassword,
                () => setState(() => showPassword = !showPassword),
              ),
              _passwordField(
                "Confirm Password",
                confirmPasswordController,
                showConfirmPassword,
                () =>
                    setState(() => showConfirmPassword = !showConfirmPassword),
              ),

              Row(
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (v) => setState(() => termsAccepted = v!),
                  ),
                  const Expanded(
                    child: Text("I agree to the Terms and Privacy Policy"),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              PrimaryButton(
                text: "Register Now",
                isLoading: _isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= USER TYPE TAB SWITCH =================
  Widget _userTypeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton("donor", "Blood Donor"),
          _tabButton("organization", "Organization"),
        ],
      ),
    );
  }

  Widget _tabButton(String type, String label) {
    final bool isActive = userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => userType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.red : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT FIELDS =================
  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Required field" : null,
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
            onPressed: toggle,
          ),
        ),
        validator: (value) =>
            value == null || value.length < 6 ? "Min 6 characters" : null,
      ),
    );
  }

  Widget _dropdownBloodGroup() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: "Blood Group",
          border: OutlineInputBorder(),
        ),
        items: [
          "A+",
          "A-",
          "B+",
          "B-",
          "AB+",
          "AB-",
          "O+",
          "O-",
        ].map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
        onChanged: (value) => bloodGroupController.text = value ?? "",
        validator: (value) => value == null ? "Select blood group" : null,
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: "Date of Birth",
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (date != null)
            dobController.text = date.toIso8601String().split('T')[0];
        },
        validator: (value) => value!.isEmpty ? "Select date" : null,
      ),
    );
  }

  // ================= SUBMIT =================
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (!termsAccepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please accept terms")));
      return;
    }

    // Construct Donor object
    final donor = Donor(
      fullName: fullNameController.text.trim(),
      bloodGroup: bloodGroupController.text.trim(),
      dob: dobController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      password: passwordController.text.trim(),
      id: '',
    );

    // Call DonorViewModel to register
    ref.read(donorViewModelProvider.notifier).registerDonor(donor);
  }
}
