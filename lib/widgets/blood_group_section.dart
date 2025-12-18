import 'package:flutter/material.dart';

class BloodGroupSection extends StatelessWidget {
  const BloodGroupSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> groups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Blood Group",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true, // important!
          physics: NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 columns → 2 rows per line
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1, // square shape
          ),
          itemBuilder: (context, index) {
            String g = groups[index];

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1), // light red
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200, width: 1.5),
              ),
              child: Center(
                child: Text(
                  g,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
