import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/reports_model.dart';

abstract class ReportsRepository {
  Future<ReportsPageData> getReportsData();
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockReportsRepository();
  } else {
    return LiveReportsRepository(apiClient);
  }
});

class LiveReportsRepository implements ReportsRepository {
  final ApiClient _apiClient;

  LiveReportsRepository(this._apiClient);

  @override
  Future<ReportsPageData> getReportsData() async {
    try {
      final responses = await Future.wait([
        _apiClient.get(
          'https://wincoconnect.com/member/reports/weekly_slips',
          options: Options(responseType: ResponseType.plain),
        ),
        _apiClient.get(
          'https://wincoconnect.com/member/topperformer',
          options: Options(responseType: ResponseType.plain),
        ),
        _apiClient.get(
          'https://wincoconnect.com/member/my_participation_report',
          options: Options(responseType: ResponseType.plain),
        ),
      ]);

      final weeklyHtml = responses[0].data?.toString() ?? '';
      final topHtml = responses[1].data?.toString() ?? '';
      final partHtml = responses[2].data?.toString() ?? '';

      if (weeklyHtml.isNotEmpty || topHtml.isNotEmpty || partHtml.isNotEmpty) {
        return ReportsPageData.fromHtml(weeklyHtml, topHtml, partHtml);
      }
      throw AppException('Failed to load Reports data from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading Reports: $e');
    }
  }
}

class MockReportsRepository implements ReportsRepository {
  @override
  Future<ReportsPageData> getReportsData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return ReportsPageData.baseline();
  }
}

