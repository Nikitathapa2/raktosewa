import 'package:flutter/material.dart';

class ActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Activity As",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 15),

        // FIRST ROW
        Row(
          children: [
            Expanded(
              child: activityCard(Icons.water_drop, "Blood Donor", "120 posts"),
            ),
            SizedBox(width: 10),
            Expanded(
              child: activityCard(
                Icons.bloodtype,
                "Blood Recipient",
                "120 posts",
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        // SECOND ROW
        Row(
          children: [
            Expanded(
              child: activityCard(Icons.add_box, "Create Post", "Donate Now!"),
            ),
            SizedBox(width: 10),
            Expanded(
              child: activityCard(Icons.favorite, "Blood Given", "1 Step Away"),
            ),
          ],
        ),
      ],
    );
  }

  Widget activityCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x61F0E7E7), // 38% opacity
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.red),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
