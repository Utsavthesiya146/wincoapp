import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/invitation_model.dart';

abstract class InvitationRepository {
  Future<InvitationsPageData> getInvitationsData();
  Future<Map<String, dynamic>> submitInvitation(InvitationSubmissionPayload payload);
}

final invitationRepositoryProvider = Provider<InvitationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockInvitationRepository();
  } else {
    return LiveInvitationRepository(apiClient);
  }
});

class LiveInvitationRepository implements InvitationRepository {
  final ApiClient _apiClient;

  LiveInvitationRepository(this._apiClient);

  @override
  Future<InvitationsPageData> getInvitationsData() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/invitations',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains('Invitations') || html.contains('AddNewInvitationsData') || html.contains('table'))) {
        return InvitationsPageData.fromHtml(html);
      }
      throw AppException('Failed to load Invitations data from live server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading Invitations: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitInvitation(InvitationSubmissionPayload payload) async {
    try {
      final formData = FormData.fromMap(payload.toFormData());
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/Invitations/AddNewInvitationsData',
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
      return {'status': 'success', 'message': 'Invitation sent successfully'};
    } on DioException catch (e) {
      final data = e.response?.data;
      return {'status': 'error', 'message': data?.toString() ?? e.message ?? 'Failed to send invitation'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

class MockInvitationRepository implements InvitationRepository {
  InvitationsPageData _data = InvitationsPageData.baseline();

  @override
  Future<InvitationsPageData> getInvitationsData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _data;
  }

  @override
  Future<Map<String, dynamic>> submitInvitation(InvitationSubmissionPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final newInv = InvitationItem(
      id: '${_data.invitations.length + 1}',
      guestName: payload.guestName,
      email: payload.guestEmail,
      phone: payload.guestPhone,
      company: payload.guestCompany,
      message: payload.message,
      status: 'Sent',
      sentAt: 'Today',
    );

    _data = InvitationsPageData(
      invitations: [newInv, ..._data.invitations],
      totalInvitations: _data.totalInvitations + 1,
    );

    return {'status': 'success', 'message': 'Invitation sent successfully'};
  }
}

