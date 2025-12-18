import 'package:flutter/material.dart';

class TopProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),

        SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nikita Thapa",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  "Kathmandu, Nepal",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),

        Spacer(),

        Icon(Icons.notifications_none, size: 26),
        SizedBox(width: 12),
        Icon(Icons.person_outline, size: 26),
      ],
    );
  }
}
