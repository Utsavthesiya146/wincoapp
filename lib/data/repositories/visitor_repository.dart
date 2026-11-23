import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/visitor_model.dart';

abstract class VisitorRepository {
  Future<VisitorsPageData> getVisitorsData();
  Future<Map<String, dynamic>> submitVisitor(VisitorSubmissionPayload payload);
}

final visitorRepositoryProvider = Provider<VisitorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockVisitorRepository();
  } else {
    return LiveVisitorRepository(apiClient);
  }
});

class LiveVisitorRepository implements VisitorRepository {
  final ApiClient _apiClient;

  LiveVisitorRepository(this._apiClient);

  @override
  Future<VisitorsPageData> getVisitorsData() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/visitor',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains('Visitor') || html.contains('AddNewvisitorData') || html.contains('table'))) {
        return VisitorsPageData.fromHtml(html);
      }
      throw AppException('Failed to load Visitors data from live server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading Visitors: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitVisitor(VisitorSubmissionPayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/visitor/AddNewvisitorData',
        data: formData,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        try {
          return jsonDecode(data) as Map<String, dynamic>;
        } catch (_) {
          return {'status': 'success', 'message': data};
        }
      }
      return {'status': 'success', 'message': 'Visitor registered successfully'};
    } on DioException catch (e) {
      final data = e.response?.data;
      return {'status': 'error', 'message': data?.toString() ?? e.message ?? 'Registration failed'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class MockVisitorRepository implements VisitorRepository {
  VisitorsPageData _data = VisitorsPageData.baseline();

  @override
  Future<VisitorsPageData> getVisitorsData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _data;
  }

  @override
  Future<Map<String, dynamic>> submitVisitor(VisitorSubmissionPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final newV = VisitorItem(
      id: '${_data.visitors.length + 1}',
      visitorName: payload.visitorName,
      company: payload.company,
      phone: payload.phone,
      visitedDate: payload.dateVisited,
      addedBy: 'Harri Kumar',
      status: 'Attended',
    );

    _data = VisitorsPageData(
      visitors: [newV, ..._data.visitors],
      totalVisitors: _data.totalVisitors + 1,
    );

    return {'status': 'success', 'message': 'Visitor registered successfully'};
  }
}

