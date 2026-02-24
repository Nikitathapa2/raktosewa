import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/theme/app_colors.dart';
import 'package:raktosewa/features/inventory/presentation/providers/inventory_viewmodel_provider.dart';

class ManageInventoryScreen extends ConsumerStatefulWidget {
  const ManageInventoryScreen({super.key});

  @override
  ConsumerState<ManageInventoryScreen> createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends ConsumerState<ManageInventoryScreen> {
  final List<String> _allBloodGroups = ['O+', 'A-', 'B+', 'AB+', 'O-', 'A+', 'B-', 'AB-'];
  
  final Map<String, Color> _bloodGroupColors = {
    'O+': Color(0xFFE85C5C),
    'O-': Color(0xFF5BA8D9),
    'A+': Color(0xFFE85C5C),
    'A-': Color(0xFFE85C5C),
    'B+': Color(0xFF5BA8D9),
    'B-': Color(0xFF5BA8D9),
    'AB+': Color(0xFFF5A742),
    'AB-': Color(0xFFF5A742),
  };
  
  final Map<String, String> _bloodGroupLabels = {
    'O+': 'Type O\nPositive',
    'O-': 'Type O\nNegative',
    'A+': 'Type A\nPositive',
    'A-': 'Type A\nNegative',
    'B+': 'Type B\nPositive',
    'B-': 'Type B\nNegative',
    'AB+': 'Type AB\nPositive',
    'AB-': 'Type AB\nNegative',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });
  }

  void _loadInventory() {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();
    if (token != null) {
      ref.read(inventoryViewModelProvider.notifier).fetchInventory(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Listen for success/error
    ref.listen(inventoryViewModelProvider, (previous, next) {
      if (next.isSuccess && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inventory updated successfully!'),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(inventoryViewModelProvider.notifier).resetState();
      } else if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(inventoryViewModelProvider.notifier).resetState();
      }
    });

    // Build inventory map from list
    final Map<String, int> inventory = {};
    final Map<String, DateTime> lastUpdated = {};
    for (var item in inventoryState.inventoryList) {
      inventory[item.bloodGroup] = item.quantity;
      lastUpdated[item.bloodGroup] = item.updatedAt;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Blood Inventory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.getSurfaceColor(context),
        foregroundColor: AppColors.getTextColor(context),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadInventory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: AppColors.getBackgroundColor(context),
      body: inventoryState.isLoading && inventoryState.inventoryList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allBloodGroups.length,
              itemBuilder: (context, index) {
                final bloodType = _allBloodGroups[index];
                final units = inventory[bloodType] ?? 0;
                final color = _bloodGroupColors[bloodType]!;
                final label = _bloodGroupLabels[bloodType]!;
                final updated = lastUpdated[bloodType];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildInventoryCard(
                    bloodType,
                    label,
                    units,
                    color,
                    updated,
                    isDark,
                  ),
                );
              },
            ),
    );
  }

  String _getStatusLabel(int units) {
    if (units == 0) return 'CRITICAL';
    if (units < 20) return 'LOW';
    if (units < 50) return 'STOCK';
    if (units < 80) return 'STABLE';
    return 'OPTIMAL';
  }

  Color _getStatusColor(int units) {
    if (units == 0) return const Color(0xFFE85C5C);
    if (units < 20) return const Color(0xFFE85C5C);
    if (units < 50) return const Color(0xFFF5A742);
    if (units < 80) return const Color(0xFF6B7280);
    return const Color(0xFF10B981);
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'UPDATED JUST NOW';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'UPDATED JUST NOW';
    if (difference.inMinutes < 60) return 'UPDATED ${difference.inMinutes}M AGO';
    if (difference.inHours < 24) return 'UPDATED ${difference.inHours}H AGO';
    if (difference.inDays < 7) return 'UPDATED ${difference.inDays}D AGO';
    return 'UPDATED ${difference.inDays ~/ 7}W AGO';
  }

  Widget _buildInventoryCard(
    String bloodType,
    String label,
    int units,
    Color color,
    DateTime? updated,
    bool isDark,
  ) {
    final status = _getStatusLabel(units);
    final statusColor = _getStatusColor(units);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left colored indicator
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Blood type icon and label
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          bloodType,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Blood type name and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getTimeAgo(updated),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Units display
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$units',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Units',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.remove,
                          onPressed: units > 0
                              ? () => _quickUpdate(bloodType, units, 'subtract', 1)
                              : null,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$units',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.add,
                          onPressed: () => _quickUpdate(bloodType, units, 'add', 1),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return Material(
      color: onPressed != null
          ? const Color(0xFF3B82F6)
          : (isDark ? Colors.grey[800] : Colors.grey[300]),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Future<void> _quickUpdate(
    String bloodType,
    int currentUnits,
    String operation,
    int amount,
  ) async {
    final tokenService = ref.read(tokenServiceProvider);
    final token = tokenService.getToken();

    if (token != null) {
      await ref.read(inventoryViewModelProvider.notifier).updateInventory(
        token: token,
        bloodGroup: bloodType,
        quantity: amount,
        operation: operation,
      );
    }
  }
}
