import 'dart:convert';
import 'package:manager_app/data/models/dashboard_summary.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/data/services/http_client.dart';
import 'package:manager_app/core/utils/logger.dart';

class DashboardService {
  static const String _tag = 'DashboardService';
  final HttpClient _api = HttpClient();

  Future<DashboardSummary> fetchSummary() async {
    AppLogger.i(_tag, 'fetchSummary()');
    final response = await _api.get(AppConstants.summaryEndpoint);
    if (response.statusCode == 200) {
      final summary = DashboardSummary.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'fetchSummary() parsed summary from API');
      return summary;
    }
    AppLogger.e(_tag, 'fetchSummary() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch dashboard summary (${response.statusCode})');
  }
}
