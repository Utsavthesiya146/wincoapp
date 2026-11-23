class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'referral', 'business', 'meeting', 'announcement'
  final bool isRead;
  final DateTime timestamp;
  final String? actionRoute;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    this.actionRoute,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'announcement',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actionRoute: json['action_route'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'timestamp': timestamp.toIso8601String(),
      'action_route': actionRoute,
    };
  }

  static List<NotificationModel> fromHtml(String html) {
    final list = <NotificationModel>[];
    final parts = html.split('<div class="notification-card');
    for (int i = 1; i < parts.length; i++) {
      final card = parts[i];
      final codeMatch = RegExp(r"readNotification\('([a-zA-Z0-9]+)'").firstMatch(card);
      final id = codeMatch?.group(1) ?? 'NOTI$i';

      final titleMatch = RegExp(r'<div class="notif-message">\s*<h6>\s*([^<]+)\s*</h6>').firstMatch(card);
      final title = titleMatch?.group(1)?.trim() ?? 'Notification';

      final msgMatch = RegExp(r'</h6>\s*([^<]+)\s*</div>', dotAll: true).firstMatch(card);
      final msg = msgMatch?.group(1)?.trim() ?? '';

      final isRead = card.contains('status-badge read') || card.contains('class="status-badge read"');

      String type = 'announcement';
      if (title.toLowerCase().contains('121')) {
        type = 'meeting';
      } else if (title.toLowerCase().contains('business')) {
        type = 'business';
      } else if (title.toLowerCase().contains('referral')) {
        type = 'referral';
      }

      list.add(NotificationModel(
        id: id,
        title: title,
        message: msg,
        type: type,
        isRead: isRead,
        timestamp: DateTime.now(),
      ));
    }
    return list;
  }

  static List<NotificationModel> baseline() {
    return [
      NotificationModel(
        id: 'NOTI0300',
        title: 'New 121 Received',
        message: 'Sreenivas GR sent you a new 121.',
        type: 'meeting',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 68)),
      ),
      NotificationModel(
        id: 'NOTI0024',
        title: 'Business Done Received',
        message: 'Business slip recorded for your review.',
        type: 'business',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 90)),
      ),
      NotificationModel(
        id: 'NOTI0023',
        title: 'Business Done Received',
        message: 'Business slip recorded for your review.',
        type: 'business',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 100)),
      ),
      NotificationModel(
        id: 'NOTI0022',
        title: 'Business Done Received',
        message: 'Business slip recorded for your review.',
        type: 'business',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 110)),
      ),
    ];
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? timestamp,
    String? actionRoute,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}

