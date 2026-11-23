import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockNotificationRepository();
  } else {
    return LiveNotificationRepository(apiClient);
  }
});

class LiveNotificationRepository implements NotificationRepository {
  final ApiClient _apiClient;

  LiveNotificationRepository(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/notifications',
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'},
        ),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty) {
        return NotificationModel.fromHtml(html);
      }
      return [];
    } catch (e) {
      throw AppException('Failed to load notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final formData = FormData.fromMap({
        'n_code': id,
        'status': 'read',
      });
      await _apiClient.post(
        'https://wincoconnect.com/member/notifications/edit_not_status_action',
        data: formData,
      );
    } catch (_) {}
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notifs = await getNotifications();
      for (final n in notifs) {
        if (!n.isRead) {
          await markAsRead(n.id);
        }
      }
    } catch (_) {}
  }
}

class MockNotificationRepository implements NotificationRepository {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'NOTIF-01',
      title: 'Referral Received: Brigade Metro',
      message: 'Rajesh Kulkarni referred you for high-grade concrete supply (Estimated ₹48 Lakhs).',
      type: 'referral',
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    NotificationModel(
      id: 'NOTIF-02',
      title: 'Chapter Meeting Reminder',
      message: 'WINCO Titans Bengaluru Chapter meeting this Thursday at 7:30 AM, The Grand Luxury Hotel.',
      type: 'meeting',
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    NotificationModel(
      id: 'NOTIF-03',
      title: 'Member Conclave Invitation',
      message: 'Invitations dispatched for upcoming regional business conclave.',
      type: 'announcement',
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'NOTIF-04',
      title: 'Closed Business Milestone Recognized',
      message: 'Congratulations! Your chapter has crossed ₹4 Crore in closed business this quarter.',
      type: 'announcement',
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<NotificationModel>.from(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}

