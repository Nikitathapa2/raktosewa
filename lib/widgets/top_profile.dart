import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';

class TopProfile extends ConsumerWidget {
  const TopProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSessionService = ref.read(userSessionServiceProvider);
    
    final userName = userSessionService.getCurrentUserFullName() ?? "Guest User";
    final userAddress = userSessionService.getUserAddress() ?? "Location not set";

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      userAddress,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.notifications_none, size: 26),
        SizedBox(width: 12),
        Icon(Icons.person_outline, size: 26),
      ],
    );
  }
}
