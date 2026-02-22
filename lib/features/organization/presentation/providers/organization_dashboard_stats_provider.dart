import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/organization_dashboard_stats_state.dart';
import '../viewmodels/organization_dashboard_stats_viewmodel.dart';

final organizationDashboardStatsNotifierProvider =
    NotifierProvider<OrganizationDashboardStatsNotifier, OrganizationDashboardStatsState>(
      OrganizationDashboardStatsNotifier.new,
    );
