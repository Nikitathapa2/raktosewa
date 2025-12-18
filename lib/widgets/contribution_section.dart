import 'package:flutter/material.dart';

class ContributionSection extends StatelessWidget {
  const ContributionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Our Contribution",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        Row(
          children: const [
            Expanded(
              child: _ContributionBox(
                value: "100",
                label: "Blood Donor",
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _ContributionBox(
                value: "20",
                label: "Post Everyday",
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContributionBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ContributionBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // soft background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
