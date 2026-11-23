import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/f2f_model.dart';

abstract class F2fRepository {
  Future<F2fPageData> getF2fData();
  Future<Map<String, dynamic>> submitF2f(F2fSubmissionPayload payload);
  Future<Map<String, dynamic>> updateF2fStatus(F2fStatusUpdatePayload payload);
  Future<Map<String, dynamic>> deleteF2f(String f2fCode);
}

final f2fRepositoryProvider = Provider<F2fRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockF2fRepository();
  } else {
    return LiveF2fRepository(apiClient);
  }
});

class LiveF2fRepository implements F2fRepository {
  final ApiClient _apiClient;

  LiveF2fRepository(this._apiClient);

  @override
  Future<F2fPageData> getF2fData() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/f2f',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains("My 121's") || html.contains("addNewf2fData") || html.contains("1-to-1"))) {
        return F2fPageData.fromHtml(html);
      }
      throw AppException('Failed to load 1-to-1 Meetings (F2F) data from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading 1-to-1 Meetings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitF2f(F2fSubmissionPayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/f2f/addNewf2fData',
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
      return {'status': 'success', 'message': '1-to-1 Meeting recorded successfully'};
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = 'Failed to submit 1-to-1 Meeting';
      if (data is Map && data['message'] != null) {
        errorMsg = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        errorMsg = data;
      }
      return {'status': 'error', 'message': errorMsg};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> updateF2fStatus(F2fStatusUpdatePayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/f2f/edit_f2f_action',
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
      return {'status': 'success', 'message': 'Status updated'};
    } on DioException catch (e) {
      final data = e.response?.data;
      return {'status': 'error', 'message': data?.toString() ?? e.message ?? 'Update failed'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> deleteF2f(String f2fCode) async {
    try {
      final formData = FormData.fromMap({'f2f_code': f2fCode});
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/f2f/delete_f2f_action',
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
      return {'status': 'success', 'message': 'Meeting deleted'};
    } on DioException catch (e) {
      return {'status': 'error', 'message': e.message ?? 'Delete failed'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class MockF2fRepository implements F2fRepository {
  F2fPageData _data = F2fPageData.baseline();

  @override
  Future<F2fPageData> getF2fData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _data;
  }

  @override
  Future<Map<String, dynamic>> submitF2f(F2fSubmissionPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final newMeeting = F2fMeetingItem(
      id: '${_data.meetings.length + 1}',
      f2fCode: 'F2F0099',
      fromMemberName: 'Harri Kumar',
      fromMemberEmail: 'harri@jobhunterr.com',
      toMemberName: 'Selected Member',
      toMemberEmail: 'member@test.com',
      location: payload.location,
      meetingDate: payload.date,
      status: F2fStatus.scheduled,
      createdDate: 'Today',
      summary: payload.summary,
    );

    final updatedMeetings = [newMeeting, ..._data.meetings];
    _data = F2fPageData(
      summary: F2fSummary(
        totalMeetings: updatedMeetings.length,
        scheduledCount: _data.summary.scheduledCount + 1,
        completedCount: _data.summary.completedCount,
        cancelledCount: _data.summary.cancelledCount,
      ),
      meetings: updatedMeetings,
      members: _data.members,
    );

    return {'status': 'success', 'message': '1-to-1 Meeting recorded successfully'};
  }

  @override
  Future<Map<String, dynamic>> updateF2fStatus(F2fStatusUpdatePayload payload) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final updated = _data.meetings.map((m) {
      if (m.f2fCode == payload.f2fCode) {
        return F2fMeetingItem(
          id: m.id,
          f2fCode: m.f2fCode,
          fromMemberName: m.fromMemberName,
          fromMemberEmail: m.fromMemberEmail,
          fromMemberAvatar: m.fromMemberAvatar,
          toMemberName: m.toMemberName,
          toMemberEmail: m.toMemberEmail,
          toMemberAvatar: m.toMemberAvatar,
          location: m.location,
          meetingDate: m.meetingDate,
          status: F2fStatus.fromString(payload.status),
          createdDate: m.createdDate,
          summary: payload.summary.isNotEmpty ? payload.summary : m.summary,
        );
      }
      return m;
    }).toList();

    int scheduled = 0;
    int completed = 0;
    int cancelled = 0;
    for (final item in updated) {
      if (item.status == F2fStatus.completed) {
        completed++;
      } else if (item.status == F2fStatus.cancelled) {
        cancelled++;
      } else {
        scheduled++;
      }
    }

    _data = F2fPageData(
      summary: F2fSummary(
        totalMeetings: updated.length,
        scheduledCount: scheduled,
        completedCount: completed,
        cancelledCount: cancelled,
      ),
      meetings: updated,
      members: _data.members,
    );

    return {'status': 'success', 'message': 'Updated'};
  }

  @override
  Future<Map<String, dynamic>> deleteF2f(String f2fCode) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final filtered = _data.meetings.where((m) => m.f2fCode != f2fCode).toList();
    _data = F2fPageData(
      summary: F2fSummary(
        totalMeetings: filtered.length,
        scheduledCount: _data.summary.scheduledCount > 0 ? _data.summary.scheduledCount - 1 : 0,
        completedCount: _data.summary.completedCount,
        cancelledCount: _data.summary.cancelledCount,
      ),
      meetings: filtered,
      members: _data.members,
    );
    return {'status': 'success', 'message': 'Meeting deleted'};
  }
}

