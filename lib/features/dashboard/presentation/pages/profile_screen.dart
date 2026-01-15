import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/app/routes/app_routes.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final donorViewModel = ref.read(donorViewModelProvider.notifier);
    final donorState = ref.watch(donorViewModelProvider);

    final fullName = session.getCurrentUserFullName() ?? "User";
    final email = session.getCurrentUserEmail() ?? "Not available";
    final role = session.getCurrentUserRole()?.name ?? "Donor";
    final profilePath = session.getProfilePicture(); // can be file or url


    ImageProvider avatarProvider;

    if (profilePath != null && profilePath.isNotEmpty) {
      if (profilePath.startsWith('http')) {
        avatarProvider = NetworkImage(profilePath);
      } else {
        avatarProvider = FileImage(File(profilePath));
      }
    } else {
      avatarProvider = const NetworkImage('https://thepicturesdp.in/wp-content/uploads/2025/07/profile-pic-for-instagram-girl-outdoors.jpg');
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// ---------------- Avatar ----------------
            CircleAvatar(
              radius: 55,
              backgroundImage: avatarProvider,
            ),

            const SizedBox(height: 16),

            Text(
              fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              email,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            /// ---------------- Info Card ----------------
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.person_outline,
                    title: "Role",
                    value: role,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: email,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// ---------------- Logout ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: donorState.status == AuthStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: donorState.status == AuthStatus.loading
                    ? null
                    : () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text(
                                "Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true && mounted) {
                          // Call logout
                          await donorViewModel.logout();

                          // Navigate to login screen
                          if (mounted) {
                            AppRoutes.pushReplacement(
                              context,
                              const LoginScreen(),
                            );
                          }
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
