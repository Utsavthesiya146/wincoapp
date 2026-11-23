import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/network/api_client.dart';

class MembershipApplicationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String businessName;
  final String businessCategory;
  final String since;
  final String location;
  final String? gstNumber;

  const MembershipApplicationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.businessCategory,
    required this.since,
    required this.location,
    this.gstNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'business': businessName,
      'category': businessCategory,
      'since': since,
      'location': location,
      'gst': gstNumber ?? '',
    };
  }
}

abstract class MembershipRepository {
  Future<bool> submitApplication(MembershipApplicationRequest request);
  Future<Map<String, dynamic>> checkApplicationStatus(String email);
}

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockMembershipRepository();
  } else {
    return LiveMembershipRepository(apiClient);
  }
});

class LiveMembershipRepository implements MembershipRepository {
  final ApiClient _apiClient;

  LiveMembershipRepository(this._apiClient);

  @override
  Future<bool> submitApplication(MembershipApplicationRequest request) async {
    // Submits to WINCO website registration controller /api/v1/membership/apply or web form handler
    final response = await _apiClient.post(
      '/membership/apply',
      data: request.toJson(),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<Map<String, dynamic>> checkApplicationStatus(String email) async {
    final response = await _apiClient.get(
      '/membership/status',
      queryParameters: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }
}

class MockMembershipRepository implements MembershipRepository {
  @override
  Future<bool> submitApplication(MembershipApplicationRequest request) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  @override
  Future<Map<String, dynamic>> checkApplicationStatus(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'status': 'Under Review',
      'submitted_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'chapter': 'WINCO Titans Bengaluru',
      'message': 'Your membership application is being reviewed by the Membership Committee.',
    };
  }
}

