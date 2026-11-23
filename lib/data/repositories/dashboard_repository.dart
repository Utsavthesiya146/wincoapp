import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';
import '../models/member_dashboard_model.dart';
import '../models/notification_model.dart';
import '../models/referral_model.dart';

abstract class DashboardRepository {
  Future<DashboardStatsModel> getStats();
  Future<MemberDashboardData> getMemberDashboard({String? filter});
  Future<List<ReferralModel>> getRecentReferrals();
  Future<List<NotificationModel>> getRecentActivities();
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockDashboardRepository();
  } else {
    return LiveDashboardRepository(apiClient);
  }
});

class LiveDashboardRepository implements DashboardRepository {
  final ApiClient _apiClient;

  LiveDashboardRepository(this._apiClient);

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      final response = await _apiClient.get('/dashboard/stats');
      return DashboardStatsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw AppException('Failed to load dashboard stats: $e');
    }
  }

  @override
  Future<MemberDashboardData> getMemberDashboard({String? filter}) async {
    try {
      final endpoint = filter != null && filter.isNotEmpty
          ? 'https://wincoconnect.com/member/dashboard?filter=$filter'
          : 'https://wincoconnect.com/member/dashboard';

      // Fetch dashboard and mychapter in parallel for 100% dynamic chapter parity
      final responses = await Future.wait([
        _apiClient.get(
          endpoint,
          options: Options(
            responseType: ResponseType.plain,
            headers: {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'},
          ),
        ),
        _apiClient.get(
          'https://wincoconnect.com/member/mychapter',
          options: Options(
            responseType: ResponseType.plain,
            headers: {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'},
          ),
        ).catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: '')),
      ]);

      final dashHtml = responses[0].data?.toString() ?? '';
      final myChapterHtml = responses[1].data?.toString() ?? '';

      String? chapterName;
      if (myChapterHtml.isNotEmpty) {
        final chMatch = RegExp(r'<div class="chapter-card-pro">.*?<h4>\s*([^<]+)\s*</h4>', dotAll: true).firstMatch(myChapterHtml);
        if (chMatch != null) {
          chapterName = chMatch.group(1)!.trim();
        }
      }

      if (dashHtml.isNotEmpty && (dashHtml.contains('Business Performance') || dashHtml.contains('Hello '))) {
        return MemberDashboardData.fromHtml(
          dashHtml,
          filter: filter ?? 'Lifetime',
          chapterName: chapterName,
        );
      }
      throw AppException('Unable to load live member dashboard data. Please verify your session.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading member dashboard: $e');
    }
  }

  @override
  Future<List<ReferralModel>> getRecentReferrals() async {
    final response = await _apiClient.get('/dashboard/recent-referrals');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => ReferralModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<NotificationModel>> getRecentActivities() async {
    final response = await _apiClient.get('/dashboard/activities');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStatsModel> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DashboardStatsModel.baseline();
  }

  @override
  Future<MemberDashboardData> getMemberDashboard({String? filter}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MemberDashboardData.baseline();
  }

  @override
  Future<List<ReferralModel>> getRecentReferrals() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      ReferralModel(
        id: 'REF-101',
        fromMemberId: 'MEM-001',
        fromMemberName: 'Rajesh Kulkarni',
        fromMemberCompany: 'Apex Infra Projects',
        toMemberId: 'MEM-004',
        toMemberName: 'Suresh Hegde',
        toMemberCompany: 'Hegde ReadyMix & Aggregates',
        clientName: 'Brigade Metro Substructure',
        clientPhone: '+91 9845099881',
        clientEmail: 'procure@brigademetro.com',
        referralType: 'Inside',
        connectionDegree: 'Close Contact',
        estimatedValue: 4800000.0,
        actualClosedValue: 4500000.0,
        status: ReferralStatus.closedWon,
        notes: 'Requirement for 3,500 cu.m M40 Grade concrete for pile caps.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ReferralModel(
        id: 'REF-102',
        fromMemberId: 'MEM-002',
        fromMemberName: 'Kavitha Shenoy',
        fromMemberCompany: 'Zenith Structural Engineers',
        toMemberId: 'MEM-005',
        toMemberName: 'Arun Varma',
        toMemberCompany: 'Varma Geotechnical Solutions',
        clientName: 'Prestige Tech Corridor',
        clientPhone: '+91 9886022331',
        clientEmail: 'infra@prestigegroup.in',
        referralType: 'Outside',
        connectionDegree: 'Told them you would call',
        estimatedValue: 1200000.0,
        actualClosedValue: 0.0,
        status: ReferralStatus.inDiscussion,
        notes: 'Soil stabilization and micro-piling consult for 2-level basement.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ReferralModel(
        id: 'REF-103',
        fromMemberId: 'MEM-003',
        fromMemberName: 'Vikram Joshi',
        fromMemberCompany: 'SteelMatrix Precast',
        toMemberId: 'MEM-001',
        toMemberName: 'Rajesh Kulkarni',
        toMemberCompany: 'Apex Infra Projects',
        clientName: 'NHAI Express Flyover Lot 3',
        clientPhone: '+91 9741005544',
        clientEmail: 'tenders@nhai-flyover3.gov.in',
        referralType: 'Inside',
        connectionDegree: 'Direct Introduction',
        estimatedValue: 18500000.0,
        actualClosedValue: 0.0,
        status: ReferralStatus.contacted,
        notes: 'Subcontracting tender bid for 12 girder beam installations.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<NotificationModel>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      NotificationModel(
        id: 'ACT-01',
        title: 'New Referral Closed',
        message: 'Rajesh Kulkarni passed ₹45 Lakhs business to Suresh Hegde (Apex -> Hegde ReadyMix).',
        type: 'referral',
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 'ACT-02',
        title: 'Upcoming Chapter Meeting',
        message: 'WINCO Titans Bengaluru fortnightly conclave on Thursday 7:30 AM at Grand Convention.',
        type: 'meeting',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      NotificationModel(
        id: 'ACT-03',
        title: 'Fortnight Business Slips Submitted',
        message: 'Fortnightly slip exchange report compiled and submitted.',
        type: 'announcement',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
