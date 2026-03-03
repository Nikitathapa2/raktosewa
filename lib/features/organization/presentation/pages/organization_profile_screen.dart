import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/app/routes/app_routes.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen_donor.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/features/organization/presentation/pages/edit_organization_profile_screen.dart';
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
    final session = ref.read(userSessionServiceProvider);
    profilePic = session.getProfilePicture();
    profilePicURL = ApiEndpoints.profilePicture(profilePic ?? '');
    debugPrint("profilepic:$profilePic");

    debugPrint("profilepicURL:$profilePicURL");
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizationViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orgName = session.getCurrentUserFullName() ?? 'Organization';
    final headOfOrganization = session.getHeadOfOrganization() ?? 'Head Name';
    final email = session.getCurrentUserEmail() ?? 'Not available';
    final address = session.getUserAddress() ?? 'Location not set';
    final phoneNumber = session.getCurrentUserPhoneNumber() ?? "";
    const Color primaryColor = Color(0xFFEC4C4C);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final deepText = colorScheme.onSurface;
    final mutedText = colorScheme.onSurface.withOpacity(0.65);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert, color: deepText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withOpacity(0.7), width: 3),
                    ),
                    child: ClipOval(
                      child: (profilePic != null && profilePic!.isNotEmpty)
                          ? Image.network((profilePicURL!) , fit: BoxFit.cover)
                          : Image.asset('assets/images/profile.png', fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: -4,
                    child: GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                orgName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepText,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: mutedText),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      address,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: primaryColor.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_hospital, color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Organization: Blood Bank',
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'CONTACT DETAILS',
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ContactCard(icon: Icons.person_outline, label: 'Head of Organization', value: headOfOrganization),
              const SizedBox(height: 12),
              _ContactCard(icon: Icons.call, label: 'Phone Number', value: phoneNumber),
              const SizedBox(height: 12),
              _ContactCard(icon: Icons.email, label: 'Email Address', value: email),
              const SizedBox(height: 12),
              _ContactCard(icon: Icons.location_on, label: 'Office Address', value: address),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: profileState.status == AuthStatus.loading
                      ? null
                      : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditOrganizationProfileScreen(),
                            ),
                          );

                          if (result == true && mounted) {
                            setState(() {
                              final latestSession = ref.read(userSessionServiceProvider);
                              profilePic = latestSession.getProfilePicture();
                              profilePicURL = ApiEndpoints.profilePicture(profilePic ?? '');
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: profileState.status == AuthStatus.loading
                    ? null
                    : () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true && mounted) {
                          await ref.read(organizationViewModelProvider.notifier).logout();
                          if (mounted) {
                            AppRoutes.pushReplacement(context, const LoginScreen());
                          }
                        }
                      },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: mutedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4C4C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFEC4C4C), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
