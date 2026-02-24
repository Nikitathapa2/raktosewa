import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/inventory/domain/entities/organization_blood_stock.dart';
import 'package:raktosewa/features/inventory/presentation/providers/blood_stock_providers.dart';

class BloodInventoryScreen extends ConsumerStatefulWidget {
  const BloodInventoryScreen({super.key});

  @override
  ConsumerState<BloodInventoryScreen> createState() => _BloodInventoryScreenState();
}

class _BloodInventoryScreenState extends ConsumerState<BloodInventoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch blood stock when screen loads
    Future.microtask(() {
      _fetchBloodStock();
    });
  }

  void _fetchBloodStock() {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(bloodStockListNotifierProvider.notifier).getAllBloodStock(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bloodStockListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryRed,
        title: const Text(
          'Blood Inventory',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading && state.organizations.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEC131E)),
            )
          : state.hasError && state.organizations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.errorMessage}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _fetchBloodStock,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : state.organizations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: AppColors.getSecondaryTextColor(context).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No blood inventory available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryRed,
                      onRefresh: () async {
                        _fetchBloodStock();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.organizations.length,
                        itemBuilder: (context, index) {
                          final orgStock = state.organizations[index];
                          return _OrganizationStockCard(
                            organizationStock: orgStock,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _OrganizationStockCard extends StatelessWidget {
  final OrganizationBloodStock organizationStock;

  const _OrganizationStockCard({
    required this.organizationStock,
  });

  Color _getBloodGroupColor(String bloodGroup) {
    // Colors matching the design
    const colors = {
      'O+': Color(0xFFFF5252), // Bright red/coral
      'O-': Color(0xFFFF6E40), // Red-orange
      'A+': Color(0xFFFFAB40), // Orange/yellow
      'A-': Color(0xFFFFD740), // Yellow
      'B+': Color(0xFF448AFF), // Blue
      'B-': Color(0xFF2979FF), // Darker blue
      'AB+': Color(0xFFAB47BC), // Purple
      'AB-': Color(0xFF7B1FA2), // Darker purple
    };
    return colors[bloodGroup] ?? const Color(0xFFEC131E);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.getSurfaceColor(context).withOpacity(0.7)
            : AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Organization Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              organizationStock.organization.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextColor(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Total Units Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${organizationStock.totalUnits} Units Total',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            organizationStock.organization.phoneNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.getSecondaryTextColor(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    organizationStock.organization.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Blood Groups Section
            if (organizationStock.bloodStock.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No blood stock available',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BLOOD GROUPS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getSecondaryTextColor(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Blood Groups Horizontal List
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: organizationStock.bloodStock.map((stock) {
                      return Column(
                        children: [
                          // Blood Group Circle
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: _getBloodGroupColor(stock.bloodGroup),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getBloodGroupColor(stock.bloodGroup)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                stock.bloodGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Quantity
                          Text(
                            '${stock.quantity}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Unit Label
                          Text(
                            stock.quantity == 1 ? 'UNIT' : 'UNITS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getSecondaryTextColor(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
