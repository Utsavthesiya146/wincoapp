import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/meeting_model.dart';

abstract class MeetingRepository {
  Future<MeetingsPageData> getMeetingsData();
  Future<Map<String, dynamic>> submitMeeting(MeetingSubmissionPayload payload);
}

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockMeetingRepository();
  } else {
    return LiveMeetingRepository(apiClient);
  }
});

class LiveMeetingRepository implements MeetingRepository {
  final ApiClient _apiClient;

  LiveMeetingRepository(this._apiClient);

  @override
  Future<MeetingsPageData> getMeetingsData() async {
    try {
      final meetingsResp = await _apiClient.get(
        'https://wincoconnect.com/member/meetings',
        options: Options(responseType: ResponseType.plain),
      );
      final meetingsHtml = meetingsResp.data?.toString() ?? '';

      String attendanceHtml = '';
      try {
        final attResp = await _apiClient.get(
          'https://wincoconnect.com/member/my_attendance',
          options: Options(responseType: ResponseType.plain),
        );
        attendanceHtml = attResp.data?.toString() ?? '';
      } catch (_) {}

      if (meetingsHtml.isNotEmpty && (meetingsHtml.contains('Meeting') || meetingsHtml.contains('table'))) {
        return MeetingsPageData.fromHtml(meetingsHtml, attendanceHtml);
      }
      throw AppException('Failed to load Meetings data from live server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading Meetings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitMeeting(MeetingSubmissionPayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/Meetings/AddNewMeetingData',
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
      return {'status': 'success', 'message': 'Meeting added successfully'};
    } on DioException catch (e) {
      final data = e.response?.data;
      return {'status': 'error', 'message': data?.toString() ?? e.message ?? 'Submission failed'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class MockMeetingRepository implements MeetingRepository {
  MeetingsPageData _data = MeetingsPageData.baseline();

  @override
  Future<MeetingsPageData> getMeetingsData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _data;
  }

  @override
  Future<Map<String, dynamic>> submitMeeting(MeetingSubmissionPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final newMeeting = ChapterMeetingItem(
      id: '${_data.meetings.length + 1}',
      dateTime: '${payload.date} ${payload.time}',
      eventTitle: payload.title,
      chapter: payload.chapterCode,
      location: payload.location.isNotEmpty ? payload.location : 'Chapter Venue',
      mode: payload.mode,
      status: 'Scheduled',
      meetingLink: '',
    );

    _data = MeetingsPageData(
      meetings: [newMeeting, ..._data.meetings],
      attendance: _data.attendance,
    );

    return {'status': 'success', 'message': 'Meeting scheduled successfully'};
  }
}

