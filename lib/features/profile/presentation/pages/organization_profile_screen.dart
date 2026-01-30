import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/app/routes/app_routes.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import 'package:raktosewa/features/profile/presentation/providers/profile_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raktosewa/core/utils/snackbar_utils.dart';
import 'dart:io';

class OrganizationProfileScreen extends ConsumerStatefulWidget {
  const OrganizationProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrganizationProfileScreen> createState() =>
      _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState
    extends ConsumerState<OrganizationProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? profilePic;
  String? profilePicURL;
  final List<XFile> _selectedMedia = []; // images or video

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Please enable camera/gallery permissions in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      debugPrint('Requesting camera permission');
      final hasPermission = await _requestPermission(Permission.camera);
      if (!hasPermission) {
        debugPrint('Camera permission denied');
        return;
      }

      debugPrint('Picking image from camera');
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        debugPrint('Photo picked: ${photo.path}');
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(photo);
        });
        // Upload photo to server
        debugPrint('Uploading photo to server');
        await ref
            .read(organizationViewModelProvider.notifier)
            .uploadPhoto(File(photo.path));

        // Update user session with new profile picture
        if (mounted) {
          final uploadedPhotoUrl = ref
              .read(organizationViewModelProvider)
              .uploadedImageUrl;
          profilePicURL = ApiEndpoints.profilePicture(uploadedPhotoUrl ?? '');
          debugPrint('Uploaded photo URL: $uploadedPhotoUrl');
          if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
            final userSessionService = ref.read(userSessionServiceProvider);
            await userSessionService.updateProfilePicture(uploadedPhotoUrl);
            setState(() {
              profilePic = uploadedPhotoUrl;
            });
            if (mounted) {
              SnackbarUtils.showSuccess(
                context,
                'Profile picture updated successfully',
              );
            }
          } else {
            if (mounted) {
              SnackbarUtils.showError(
                context,
                'Failed to upload profile picture',
              );
            }
          }
        }
      } else {
        debugPrint('No photo selected');
      }
    } catch (e) {
      debugPrint('Error in _pickFromCamera: $e');
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  // code for gallery
  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      debugPrint('Picking from gallery, allowMultiple: $allowMultiple');
      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );

        if (images.isNotEmpty) {
          debugPrint('${images.length} images picked');
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.addAll(images);
          });
          // Upload first photo to server
          debugPrint('Uploading first image to server');
          await ref
              .read(organizationViewModelProvider.notifier)
              .uploadPhoto(File(images.first.path));

          // Update user session with new profile picture
          if (mounted) {
            final uploadedPhotoUrl = ref
                .read(organizationViewModelProvider)
                .uploadedImageUrl;
            profilePicURL = ApiEndpoints.profilePicture(uploadedPhotoUrl ?? '');
            debugPrint('Uploaded image URL: $uploadedPhotoUrl');
            if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
              final userSessionService = ref.read(userSessionServiceProvider);
              await userSessionService.updateProfilePicture(uploadedPhotoUrl);
              setState(() {
                profilePic = uploadedPhotoUrl;
              });
              if (mounted) {
                SnackbarUtils.showSuccess(
                  context,
                  'Profile picture updated successfully',
                );
              }
            } else {
              if (mounted) {
                SnackbarUtils.showError(
                  context,
                  'Failed to upload profile picture',
                );
              }
            }
          }
        } else {
          debugPrint('No images selected');
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          debugPrint('Image picked: ${image.path}');
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.add(image);
          });
          // Upload photo to server
          debugPrint('Uploading image to server');
          await ref
              .read(organizationViewModelProvider.notifier)
              .uploadPhoto(File(image.path));

          // Update user session with new profile picture
          if (mounted) {
            final uploadedPhotoUrl = ref
                .read(organizationViewModelProvider)
                .uploadedImageUrl;
            profilePicURL = ApiEndpoints.profilePicture(uploadedPhotoUrl ?? '');
            debugPrint('Uploaded image URL: $uploadedPhotoUrl');
            if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
              final userSessionService = ref.read(userSessionServiceProvider);
              await userSessionService.updateProfilePicture(uploadedPhotoUrl);
              setState(() {
                profilePic = uploadedPhotoUrl;
              });
              if (mounted) {
                SnackbarUtils.showSuccess(
                  context,
                  'Profile picture updated successfully',
                );
              }
            } else {
              if (mounted) {
                SnackbarUtils.showError(
                  context,
                  'Failed to upload profile picture',
                );
              }
            }
          }
        } else {
          debugPrint('No image selected');
        }
      }
    } catch (e) {
      debugPrint('Gallery Error: $e');
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _pickMedia() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Open Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.browse_gallery),
                title: const Text('Open Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(organizationProfileViewModelProvider.notifier).loadProfile(),
    );
    final session = ref.read(userSessionServiceProvider);
    profilePic = session.getProfilePicture();
    profilePicURL = ApiEndpoints.profilePicture(profilePic ?? '');
    debugPrint("profilepic:$profilePic");

    debugPrint("profilepicURL:$profilePicURL");
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizationProfileViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final orgName = session.getCurrentUserFullName() ?? 'Organization';
    final email = session.getCurrentUserEmail() ?? 'Not available';
    final address = session.getUserAddress() ?? 'Location not set';
    final phoneNumber = session.getCurrentUserPhoneNumber() ?? "";
    const Color primaryColor = Color(0xFFec1313);
    const Color backgroundColor = Color(0xFFf8f6f6);
    const Color editPurple = Color(0xFFe8e1f5);
    const Color editPurpleText = Color(0xFF6b4fa3);
    const Color darkText = Color(0xFF181111);
    const Color brownGray = Color(0xFF896161);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Top Navigation Bar
                  Container(
                    color: backgroundColor.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const Text(
                            'Organization Profile',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: darkText),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFe6dbdb)),

                  // Profile Header with Logo
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[100]!, backgroundColor],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        // Organization Logo
                        GestureDetector(
                          onTap: _pickMedia,
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  (profilePic != null && profilePic!.isNotEmpty)
                                  ? Image.network(
                                      profilePicURL ?? '',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/profile.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Organization Name
                        Text(
                          orgName,
                          style: TextStyle(
                            color: darkText,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Organization Type
                        const Text(
                          'CERTIFIED BLOOD BANK',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: brownGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              address,
                              style: TextStyle(
                                color: brownGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Requests',
                            value: '1,240',
                            valueColor: darkText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Successful Donations',
                            value: '850',
                            valueColor: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contact Information Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ContactCard(
                          icon: Icons.mail_outline,
                          label: 'Email',
                          value: email,
                        ),
                        const SizedBox(height: 12),
                        _ContactCard(
                          icon: Icons.call_outlined,
                          label: 'Phone',
                          value: phoneNumber,
                        ),
                        const SizedBox(height: 12),
                        _ContactCard(
                          icon: Icons.map_outlined,
                          label: 'Address',
                          value: address,
                        ),
                        const SizedBox(height: 12),
                        _ContactCard(
                          icon: Icons.schedule_outlined,
                          label: 'Operating Hours',
                          value: 'Mon - Fri: 08:00 - 20:00',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),

            // Bottom Action Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.9),
                      backgroundColor.withOpacity(0),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: profileState.status == AuthStatus.loading
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Edit Organization Info coming soon',
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.edit, color: editPurpleText),
                        label: const Text('Edit Organization Info'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: editPurple,
                          foregroundColor: editPurpleText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: profileState.status == AuthStatus.loading
                          ? null
                          : () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldLogout == true && mounted) {
                                await ref
                                    .read(
                                      organizationViewModelProvider.notifier,
                                    )
                                    .logout();
                                if (mounted) {
                                  AppRoutes.pushReplacement(
                                    context,
                                    const LoginScreen(),
                                  );
                                }
                              }
                            },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFe6dbdb), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF896161),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFe6dbdb), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFec1313),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF896161),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF181111),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
