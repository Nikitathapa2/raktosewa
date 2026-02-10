import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/app/routes/app_routes.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/profile/presentation/providers/profile_providers.dart';
import 'package:raktosewa/core/utils/snackbar_utils.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';

class DonorProfileScreen extends ConsumerStatefulWidget {
  const DonorProfileScreen({Key? key}) : super(key: key);

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
    // Load donor profile on open
    Future.microtask(
      () => ref.read(donorProfileViewModelProvider.notifier).loadProfile(),
    );
    // Initialize profile picture from session
    final session = ref.read(userSessionServiceProvider);
    profilePic = session.getProfilePicture();
    profilePicURL = ApiEndpoints.profilePicture(profilePic ?? '');
    debugPrint("profilepic:$profilePic");

    debugPrint("profilepicURL:$profilePicURL");
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(donorProfileViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final fullName = session.getCurrentUserFullName() ?? 'Donor';
    final email = session.getCurrentUserEmail() ?? 'Not available';
    final address = session.getUserAddress() ?? 'Location not set';
    final phoneNumber = session.getCurrentUserPhoneNumber() ?? "";

    const Color primaryColor = Color(0xFFec1313);
    const Color accentPurple = Color(0xFFa78bfa);
    const Color darkText = Color(0xFF181111);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with red background
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(30, 0, 0, 0),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top navigation bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile image
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(40, 0, 0, 0),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: (profilePic != null && profilePic!.isNotEmpty)
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
                  ],
                ),
              ),
              // Profile card
              Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            color: darkText,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Blood group badge
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.opacity,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Blood Group: A+',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Stats grid
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(value: '12', label: 'Donations'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                value: '36',
                                label: 'Lives Saved',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Contact Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'CONTACT INFORMATION',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ContactCard(
                      icon: Icons.mail_outline,
                      label: 'Email Address',
                      value: email,
                    ),
                    _ContactCard(
                      icon: Icons.call_outlined,
                      label: 'Phone Number',
                      value: phoneNumber,
                    ),
                    _ContactCard(
                      icon: Icons.location_on_outlined,
                      label: 'Residential Address',
                      value: address,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: profileState.status == AuthStatus.loading
                          ? null
                          : () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                        shadowColor: accentPurple.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
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
                          await ref
                              .read(donorViewModelProvider.notifier)
                              .logout();
                          if (mounted) {
                            AppRoutes.pushReplacement(
                              context,
                              const LoginScreen(),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[50]!, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFec1313),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFec1313).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFFec1313), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF181111),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
