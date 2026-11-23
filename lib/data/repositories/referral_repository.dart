import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/mitb_model.dart';
import '../models/referral_model.dart';

abstract class ReferralRepository {
  Future<ReferralPageData> getConnectData();
  Future<List<MitbMemberOption>> getMembers({required String type});
  Future<Map<String, dynamic>> submitReferral(ReferralSubmissionPayload payload);
  Future<Map<String, dynamic>> updateReferralStatus(ReferralStatusUpdatePayload payload);
}

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockReferralRepository();
  } else {
    return LiveReferralRepository(apiClient);
  }
});

class LiveReferralRepository implements ReferralRepository {
  final ApiClient _apiClient;

  LiveReferralRepository(this._apiClient);

  @override
  Future<ReferralPageData> getConnectData() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/connect',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains('Total Referral') || html.contains('Received Referral') || html.contains('Connect'))) {
        return ReferralPageData.fromHtml(html);
      }
      throw AppException('Failed to load Referrals data from live server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading Referrals: $e');
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
      throw AppException('Failed to load referral members: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitReferral(ReferralSubmissionPayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/connect/AddNewReferralData',
        data: formData,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      }
      return {'status': 'success', 'message': 'Referral Added Successfully & Email Sent'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> updateReferralStatus(ReferralStatusUpdatePayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/connect/edit_refferral_status_action',
        data: formData,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      }
      return {'status': 'success', 'message': 'Status Updated Successfully'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class MockReferralRepository implements ReferralRepository {
  @override
  Future<ReferralPageData> getConnectData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return ReferralPageData.baseline();
  }

  @override
  Future<List<MitbMemberOption>> getMembers({required String type}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockConnectMembers;
  }

  @override
  Future<Map<String, dynamic>> submitReferral(ReferralSubmissionPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'status': 'success',
      'message': 'Referral Added Successfully & Email Sent',
    };
  }

  @override
  Future<Map<String, dynamic>> updateReferralStatus(ReferralStatusUpdatePayload payload) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'status': 'success',
      'message': 'Updated',
    };
  }
}

final List<MitbMemberOption> _mockConnectMembers = [
  const MitbMemberOption(userCode: 'USR00015', name: 'Santhosha H R', isSelf: false),
  const MitbMemberOption(userCode: 'USR00023', name: 'A ABDUL WAJID', isSelf: false),
  const MitbMemberOption(userCode: 'USR00024', name: 'Ramesh Babu', isSelf: false),
  const MitbMemberOption(userCode: 'USR00025', name: 'Dr. Suresh Kumar', isSelf: false),
];
