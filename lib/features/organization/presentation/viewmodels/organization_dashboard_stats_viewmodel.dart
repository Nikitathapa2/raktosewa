import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/organization_dashboard_providers.dart';
import '../state/organization_dashboard_stats_state.dart';

class OrganizationDashboardStatsNotifier
    extends Notifier<OrganizationDashboardStatsState> {
  @override
  OrganizationDashboardStatsState build() {
    return const OrganizationDashboardStatsState();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final usecase = ref.read(getOrganizationDashboardStatsUsecaseProvider);
      final stats = await usecase();
      state = state.copyWith(
        isLoading: false,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
