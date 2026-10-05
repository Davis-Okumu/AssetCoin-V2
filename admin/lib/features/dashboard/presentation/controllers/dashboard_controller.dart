import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dashboard_repository.dart';
import '../../domain/dashboard.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, Dashboard>(
      DashboardController.new,
    );

class DashboardController extends AsyncNotifier<Dashboard> {
  @override
  Future<Dashboard> build() {
    return ref.read(dashboardRepositoryProvider).getDashboard();
  }

  Future<void> refreshDashboard() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).getDashboard(),
    );
  }
}
