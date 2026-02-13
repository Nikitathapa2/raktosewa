import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';

class EditDonorProfileScreen extends ConsumerStatefulWidget {
  const EditDonorProfileScreen({super.key});

  @override
  ConsumerState<EditDonorProfileScreen> createState() =>
      _EditDonorProfileScreenState();
}

class _EditDonorProfileScreenState
    extends ConsumerState<EditDonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _dateOfBirthController;
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    final userSession = ref.read(userSessionServiceProvider);
    _fullNameController =
        TextEditingController(text: userSession.getCurrentUserFullName());
    _emailController =
        TextEditingController(text: userSession.getCurrentUserEmail());
    _phoneController =
        TextEditingController(text: userSession.getCurrentUserPhoneNumber());
    _addressController =
        TextEditingController(text: userSession.getUserAddress());
    _dateOfBirthController = TextEditingController(text: userSession.getUserDateOfBirth());
    _selectedBloodGroup = userSession.getUserBloodGroup();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFec1313),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(donorViewModelProvider);

    ref.listen(donorViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.success && previous?.status == AuthStatus.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        Navigator.pop(context, true);
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Edit Donor Profile'),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: Icon(Icons.bloodtype, color: AppColors.primaryRed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(context),
                ),
                items: _bloodGroups.map((String bloodGroup) {
                  return DropdownMenuItem<String>(
                    value: bloodGroup,
                    child: Text(bloodGroup),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _dateOfBirthController,
                label: 'Date of Birth',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: editProfileState.status == AuthStatus.loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final userSession =
                                ref.read(userSessionServiceProvider);
                            final userId = userSession.getCurrentUserId();

                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User session not found'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final profile = Donor(
                              id: userId,
                              fullName: _fullNameController.text.trim(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim().isEmpty
                                  ? null
                                  : _phoneController.text.trim(),
                              address: _addressController.text.trim().isEmpty
                                  ? null
                                  : _addressController.text.trim(),
                              bloodGroup: _selectedBloodGroup ?? 'A+',
                              dateOfBirth: _dateOfBirthController.text.trim().isEmpty
                                  ? null
                                  : _dateOfBirthController.text.trim(),
                              password: '', // Not updating password
                            );

                            await ref
                                .read(donorViewModelProvider.notifier)
                                .updateProfile(profile);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: editProfileState.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Builder(
      builder: (context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
          prefixIcon: Icon(icon, color: AppColors.primaryRed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.getBorderColor(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.getBorderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: AppColors.getSurfaceColor(context),
        ),
      ),
    );
  }
}
