import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import '../features/blood_requests/presentation/pages/donor_blood_requests_screen.dart';
import '../features/blood_requests/presentation/pages/blood_request_detail_screen.dart';
import '../features/blood_requests/presentation/providers/request_list_providers.dart';
import '../widgets/blood_request_card_horizontal.dart';

class BloodRequestCarousel extends ConsumerWidget {
  const BloodRequestCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donorBloodRequestsProvider);

    // Get first 5 requests
    final requests = state.requests.take(5).toList();

    if (state.isLoading && requests.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFEC131E),
          ),
        ),
      );
    }

    // Show error only if there's no cached data
    if (state.errorMessage != null && requests.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bloodtype,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No blood requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If we have no requests and not loading/error
    if (requests.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bloodtype,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No blood requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with View All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Blood Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:  AppColors.getTextColor(context),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorBloodRequestsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC131E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: requests
                .map(
                  (request) => BloodRequestCardHorizontal(
                    request: request,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BloodRequestDetailScreen(
                            request: request,
                          ),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
