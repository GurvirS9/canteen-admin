import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/dashboard_summary.dart';
import 'package:manager_app/data/services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>(
  (ref) => DashboardService(),
);

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardSummary>>((
      ref,
    ) {
      return DashboardNotifier(ref.read(dashboardServiceProvider));
    });

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardSummary>> {
  final DashboardService _service;

  DashboardNotifier(this._service) : super(const AsyncLoading()) {
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    state = const AsyncLoading();
    try {
      final summary = await _service.fetchSummary();
      state = AsyncData(summary);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
