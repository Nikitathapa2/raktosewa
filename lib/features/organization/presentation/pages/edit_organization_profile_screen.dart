import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';

class EditOrganizationProfileScreen extends ConsumerStatefulWidget {
  const EditOrganizationProfileScreen({super.key});

  @override
  ConsumerState<EditOrganizationProfileScreen> createState() =>
      _EditOrganizationProfileScreenState();
}

class _EditOrganizationProfileScreenState
    extends ConsumerState<EditOrganizationProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _organizationNameController;
  late final TextEditingController _headOfOrganizationController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final userSession = ref.read(userSessionServiceProvider);
    _organizationNameController =
        TextEditingController(text: userSession.getCurrentUserFullName());
    _headOfOrganizationController = TextEditingController(
      text: userSession.getHeadOfOrganization());
    _emailController =
        TextEditingController(text: userSession.getCurrentUserEmail());
    _phoneController =
        TextEditingController(text: userSession.getCurrentUserPhoneNumber());
    _addressController =
        TextEditingController(text: userSession.getUserAddress());
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _headOfOrganizationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(organizationViewModelProvider);

    ref.listen(organizationViewModelProvider, (previous, next) {
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
        title: const Text('Edit Organization Profile'),
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
                controller: _organizationNameController,
                label: 'Organization Name',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter organization name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _headOfOrganizationController,
                label: 'Head of Organization',
                icon: Icons.person_outline,
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

                            final profile = Organization(
                              id: userId,
                              organizationName:
                                  _organizationNameController.text.trim(),
                              headOfOrganization:
                                  _headOfOrganizationController.text.trim().isEmpty
                                      ? ''
                                      : _headOfOrganizationController.text
                                          .trim(),
                              email: _emailController.text.trim(),
                              phoneNumber: _phoneController.text.trim().isEmpty
                                  ? null
                                  : _phoneController.text.trim(),
                              address: _addressController.text.trim().isEmpty
                                  ? null
                                  : _addressController.text.trim(),
                              password: '', // Not updating password
                              role: 'ORGANIZATION',
                            );

                            await ref
                                .read(organizationViewModelProvider.notifier)
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
    String? Function(String?)? validator,
  }) {
    return Builder(
      builder: (context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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
