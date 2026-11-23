import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/mitb_model.dart';

abstract class MitbRepository {
  Future<MitbPageData> getMitbData();
  Future<List<MitbMemberOption>> getMembers({required String type});
  Future<Map<String, dynamic>> submitMitb(MitbSubmissionPayload payload);
}

final mitbRepositoryProvider = Provider<MitbRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockMitbRepository();
  } else {
    return LiveMitbRepository(apiClient);
  }
});

class LiveMitbRepository implements MitbRepository {
  final ApiClient _apiClient;

  LiveMitbRepository(this._apiClient);

  @override
  Future<MitbPageData> getMitbData() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/mitb',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains('Business Revenue') || html.contains('Business Received') || html.contains('Money In The Bank'))) {
        return MitbPageData.fromHtml(html);
      }
      throw AppException('Failed to load Business Done (MITB) data from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading Business Done: $e');
    }
  }

  @override
  Future<List<MitbMemberOption>> getMembers({required String type}) async {
    try {
      final formData = FormData.fromMap({'type': type});
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/connect/getMembers',
        data: formData,
      );

      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is List) list = decoded;
      }

      return list
          .map((e) => MitbMemberOption.fromJson(e as Map<String, dynamic>))
          .where((m) => !m.isSelf && m.userCode.isNotEmpty)
          .toList();
    } catch (e) {
      throw AppException('Failed to load member options: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitMitb(MitbSubmissionPayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/mitb/addNewmitbData',
        data: formData,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      }
      return {'status': 'success', 'message': 'Business Done Added Successfully'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class MockMitbRepository implements MitbRepository {
  @override
  Future<MitbPageData> getMitbData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MitbPageData.baseline();
  }

  @override
  Future<List<MitbMemberOption>> getMembers({required String type}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockMembers;
  }

  @override
  Future<Map<String, dynamic>> submitMitb(MitbSubmissionPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'status': 'success',
      'message': 'Business Done Added Successfully & Email Sent',
    };
  }
}

final List<MitbMemberOption> _mockMembers = [
  const MitbMemberOption(userCode: 'USR00002', name: 'Dr. Rajesh Sharma', isSelf: false),
  const MitbMemberOption(userCode: 'USR00003', name: 'Priya Sundaram', isSelf: false),
  const MitbMemberOption(userCode: 'USR00004', name: 'Vikram Mehta', isSelf: false),
  const MitbMemberOption(userCode: 'USR00015', name: 'Santhosha H R', isSelf: false),
  const MitbMemberOption(userCode: 'USR00023', name: 'A ABDUL WAJID', isSelf: false),
];

