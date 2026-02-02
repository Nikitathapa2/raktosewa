import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/campaign.dart';
import '../providers/campaign_presentation_providers.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  final Campaign? initialCampaign;

  const CreateCampaignScreen({super.key, this.initialCampaign});

  @override
  ConsumerState<CreateCampaignScreen> createState() =>
      _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime? _selectedDate;
  XFile? _selectedImage;
  String? _existingImageName;

  bool get _isEdit => widget.initialCampaign != null;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialCampaign;
    if (initial != null) {
      _titleController.text = initial.title;
      _descriptionController.text = initial.description;
      _locationController.text = initial.location;
      _startTimeController.text = initial.startTime;
      _endTimeController.text = initial.endTime;
      _selectedDate = initial.date;
      _existingImageName = initial.imageName;
      _dateController.text =
          '${initial.date.year}-${initial.date.month.toString().padLeft(2, '0')}-${initial.date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCampaignViewModelProvider);

    ref.listen(createCampaignViewModelProvider, (previous, next) {
      if (previous?.isSuccess != true && next.isSuccess) {
        final message = _isEdit
            ? 'Campaign updated successfully!'
            : 'Campaign created successfully!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.pop(context, true);
            ref.read(createCampaignViewModelProvider.notifier).resetState();
          }
        });
      } else if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(createCampaignViewModelProvider.notifier).resetState();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Campaign' : 'Create Campaign'),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextColor(context),
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit
                      ? 'Update Blood Donation Campaign'
                      : 'New Blood Donation Campaign',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEdit
                      ? 'Update the campaign details'
                      : 'Organize a blood donation drive',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 24),

                _buildImagePicker(),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _titleController,
                  label: 'Campaign Title',
                  icon: Icons.campaign_outlined,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                _buildDateField(
                  controller: _dateController,
                  label: 'Campaign Date',
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        controller: _startTimeController,
                        label: 'Start Time',
                        icon: Icons.access_time_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        controller: _endTimeController,
                        label: 'End Time',
                        icon: Icons.access_time_filled_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submitCampaign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6C23E),
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
                        : Text(
                            _isEdit ? 'Update Campaign' : 'Create Campaign',
                            style: const TextStyle(
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
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _selectedImage != null || _existingImageName != null;
    final imageUrl = _existingImageName == null
        ? null
        : '${ApiEndpoints.mediaServerUrl}/campaigns/$_existingImageName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campaign Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(context)),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          imageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('Image failed to load'),
                            );
                          },
                        ),
                )
              : Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
        if (_selectedImage != null || _existingImageName != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _existingImageName = null;
              });
            },
            child: const Text('Remove image'),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.getTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
        prefixIcon: Icon(icon, color: const Color(0xFFF6C23E)),
        filled: true,
        fillColor: AppColors.getSurfaceColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF6C23E), width: 2),
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: AppColors.getTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
        prefixIcon: Icon(icon, color: const Color(0xFFF6C23E)),
        filled: true,
        fillColor: AppColors.getSurfaceColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF6C23E), width: 2),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          _selectedDate = date;
          controller.text =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: AppColors.getTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
        prefixIcon: Icon(icon, color: const Color(0xFFF6C23E)),
        filled: true,
        fillColor: AppColors.getSurfaceColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF6C23E), width: 2),
        ),
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          controller.text = time.format(context);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  void _submitCampaign() {
    if (_formKey.currentState!.validate()) {
      // Get user session
      final userSession = ref.read(userSessionServiceProvider);
      final organizationId = userSession.getCurrentUserId();

      if (organizationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get fresh token
      final tokenService = ref.read(tokenServiceProvider);
      final token = tokenService.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create campaign entity
      final campaign = Campaign(
        id: widget.initialCampaign?.id,
        organization: organizationId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        location: _locationController.text.trim(),
        imageName: _existingImageName,
      );

      // Call the viewmodel
      final notifier = ref.read(createCampaignViewModelProvider.notifier);
      final imagePath = _selectedImage?.path;

      if (_isEdit && campaign.id != null) {
        notifier.updateCampaign(
          campaign.id!,
          campaign,
          token,
          imagePath: imagePath,
        );
      } else {
        notifier.createCampaign(campaign, token, imagePath: imagePath);
      }
    }
  }
}
