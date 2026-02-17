import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/walkin_donation.dart';
import '../providers/walkin_donation_presentation_providers.dart';

class WalkinDonorScreen extends ConsumerStatefulWidget {
  const WalkinDonorScreen({super.key});

  @override
  ConsumerState<WalkinDonorScreen> createState() => _WalkinDonorScreenState();
}

class _WalkinDonorScreenState extends ConsumerState<WalkinDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _unitsController = TextEditingController();
  String _gender = 'MALE';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerWalkinDonationViewModelProvider);
    
    // Listen to state changes
    ref.listen(registerWalkinDonationViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Walk-in donation recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk-in Donor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register Walk-in Donation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record donation from a walk-in donor',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Donor Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _bloodGroupController.text.isEmpty ? null : _bloodGroupController.text,
                label: 'Blood Group',
                icon: Icons.bloodtype_outlined,
                items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                onChanged: (value) {
                  setState(() {
                    _bloodGroupController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _gender,
                label: 'Gender',
                icon: Icons.wc_outlined,
                items: const ['MALE', 'FEMALE', 'OTHER'],
                onChanged: (value) {
                  setState(() {
                    _gender = value ?? 'MALE';
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _unitsController,
                label: 'Units Donated',
                icon: Icons.water_drop_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E73DF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Record Donation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4E73DF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4E73DF), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4E73DF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4E73DF), width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  void _submitDonation() {
    if (_formKey.currentState!.validate()) {
      // Get user session
      final userSession = ref.read(userSessionServiceProvider);
      final organizationId = userSession.getCurrentUserId();

      if (organizationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organization not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate blood group selection
      if (_bloodGroupController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a blood group'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create walk-in donation entity
      final donation = WalkinDonation(
        organization: organizationId,
        donorName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        bloodGroup: _bloodGroupController.text.trim(),
        gender: _gender,
        unitsdonated: int.tryParse(_unitsController.text) ?? 0,
      );

      // Call the viewmodel
      ref.read(registerWalkinDonationViewModelProvider.notifier).registerDonation(donation);
    }
  }
}