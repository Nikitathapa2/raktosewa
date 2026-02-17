import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/app/routes/app_routes.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen_donor.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/core/utils/snackbar_utils.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/features/donor/presentation/pages/edit_donor_profile_screen.dart';

class DonorProfileScreen extends ConsumerStatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  ConsumerState<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends ConsumerState<DonorProfileScreen> {
  //for photo upload
  String? profilePic;
  String? profilePicURL;

  // Media selection
  final List<XFile> _selectedMedia = []; // images or video
  final ImagePicker _imagePicker = ImagePicker();
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

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
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // code for camera
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
            .read(donorViewModelProvider.notifier)
            .uploadPhoto(File(photo.path));

        // Update user session with new profile picture
        if (mounted) {
          final uploadedPhotoUrl = ref
              .read(donorViewModelProvider)
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
              .read(donorViewModelProvider.notifier)
              .uploadPhoto(File(images.first.path));

          // Update user session with new profile picture
          if (mounted) {
            final uploadedPhotoUrl = ref
                .read(donorViewModelProvider)
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
              .read(donorViewModelProvider.notifier)
              .uploadPhoto(File(image.path));

          // Update user session with new profile picture
          if (mounted) {
            final uploadedPhotoUrl = ref
                .read(donorViewModelProvider)
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

  // code for video
  Future<void> _pickFromVideo() async {
    try {
      final hasPermission = await _requestPermission(Permission.camera);
      if (!hasPermission) return;

      final hasMicPermission = await _requestPermission(Permission.microphone);
      if (!hasMicPermission) return;

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1),
      );

      if (video != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(video);
        });
        // Upload video to server
        // await ref
        //     .read(itemViewModelProvider.notifier)
        //     .uploadVideo(File(video.path));
      }
    } catch (e) {
      _showPermissionDeniedDialog();
    }
  }

  // code for dialogBox : showDialog for menu
  Future<void> _pickMedia() async {
    try {
      debugPrint('Opening media picker bottom sheet');
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text('Open Camera'),
                  onTap: () {
                    debugPrint('Camera option tapped');
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.browse_gallery),
                  title: Text('Open Gallery'),
                  onTap: () {
                    debugPrint('Gallery option tapped');
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.video_call),
                  title: Text('Record Video'),
                  onTap: () {
                    debugPrint('Video option tapped');
                    Navigator.pop(context);
                    _pickFromVideo();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening media picker: $e');
      if (mounted) {
        SnackbarUtils.showError(context, 'Error opening media picker: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize profile picture from session
    final session = ref.read(userSessionServiceProvider);
    profilePic = session.getProfilePicture();
    profilePicURL = ApiEndpoints.profilePicture(profilePic ?? '');
    debugPrint("profilepic:$profilePic");

    debugPrint("profilepicURL:$profilePicURL");
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(donorViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fullName = session.getCurrentUserFullName() ?? 'Donor';
    final email = session.getCurrentUserEmail() ?? 'Not available';
    final address = session.getUserAddress() ?? 'Location not set';
    final phoneNumber = session.getCurrentUserPhoneNumber() ?? "";
    final bloodGroup = session.getUserBloodGroup() ?? "N/A";
    final dateofBirth = session.getUserDateOfBirth() ?? "N/A";

    const Color primaryColor = Color(0xFFEC4C4C);
    final deepText = colorScheme.onSurface;
    final mutedText = colorScheme.onSurface.withOpacity(0.65);
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
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
                          ? Image.network(profilePicURL ?? '', fit: BoxFit.cover)
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
                fullName,
                style: TextStyle(
                  color: deepText,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: mutedText),
                  const SizedBox(width: 4),
                  Text(
                    address,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                    const Icon(Icons.bloodtype, color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Text(
                     bloodGroup,
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
              _ContactCard(icon: Icons.call, label: 'Phone Number', value: phoneNumber),
              const SizedBox(height: 12),
              _ContactCard(icon: Icons.email, label: 'Email Address', value: email),
              const SizedBox(height: 12),
              _ContactCard(icon: Icons.location_on, label: 'Address', value: address),
              const SizedBox(height: 28),
              _ContactCard(icon: Icons.calendar_month, label: "Date of Birth", value: dateofBirth),
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
                              builder: (context) => const EditDonorProfileScreen(),
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
                onPressed: () async {
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
                    await ref.read(donorViewModelProvider.notifier).logout();
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
