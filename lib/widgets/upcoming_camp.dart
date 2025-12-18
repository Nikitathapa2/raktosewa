import 'package:flutter/material.dart';

class UpcomingCamps extends StatelessWidget {
  const UpcomingCamps({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Camps",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 16),

        _CampCard(
          title: "Blood Donation Camp",
          location: "Red Cross Society Nepal",
          time: "9:00 AM - 4:00 PM",
          imagePath: "assets/images/camp1.png",
        ),

        const SizedBox(height: 16),

        _CampCard(
          title: "Community Drive",
          location: "Nepal Youth Foundation",
          time: "10:00 AM - 2:00 PM",
          imagePath: "assets/images/camp2.png",
        ),
      ],
    );
  }
}

class _CampCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String imagePath;

  const _CampCard({
    required this.title,
    required this.location,
    required this.time,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        // ⭐ Added Stroke / Border
        border: Border.all(color: Colors.grey.shade300, width: 1.2),

        // Smooth shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 110,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 16),

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),
                Text(location, style: TextStyle(color: Colors.grey.shade700)),
                Text(time, style: TextStyle(color: Colors.grey.shade600)),

                const SizedBox(height: 12),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
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
