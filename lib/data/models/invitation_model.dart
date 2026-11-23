class InvitationItem {
  final String id;
  final String guestName;
  final String email;
  final String phone;
  final String company;
  final String message;
  final String status;
  final String sentAt;

  const InvitationItem({
    required this.id,
    required this.guestName,
    required this.email,
    required this.phone,
    required this.company,
    required this.message,
    required this.status,
    required this.sentAt,
  });

  factory InvitationItem.fromJson(Map<String, dynamic> json) {
    return InvitationItem(
      id: json['id']?.toString() ?? '',
      guestName: json['guest_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Sent',
      sentAt: json['sent_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'email': email,
      'phone': phone,
      'company': company,
      'message': message,
      'status': status,
      'sent_at': sentAt,
    };
  }
}

class InvitationSubmissionPayload {
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String guestCompany;
  final String message;

  const InvitationSubmissionPayload({
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.guestCompany,
    required this.message,
  });

  Map<String, dynamic> toFormData() {
    return {
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'guest_company': guestCompany,
      'message': message,
    };
  }
}

class InvitationsPageData {
  final List<InvitationItem> invitations;
  final int totalInvitations;

  const InvitationsPageData({
    required this.invitations,
    required this.totalInvitations,
  });

  factory InvitationsPageData.baseline() {
    return const InvitationsPageData(
      invitations: [],
      totalInvitations: 0,
    );
  }

  factory InvitationsPageData.fromHtml(String html) {
    final list = <InvitationItem>[];
    if (html.contains('No Invitations Found')) {
      return const InvitationsPageData(invitations: [], totalInvitations: 0);
    }

    final rowMatches = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true, caseSensitive: false).allMatches(html);
    for (final rm in rowMatches) {
      final row = rm.group(1)!;
      final tds = RegExp(r'<td[^>]*>(.*?)</td>', dotAll: true, caseSensitive: false).allMatches(row).toList();
      if (tds.length >= 7) {
        final id = tds[0].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (int.tryParse(id) == null) continue;

        final guestName = tds[1].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final email = tds[2].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final phone = tds[3].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final company = tds[4].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final message = tds[5].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final status = tds[6].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final sentAt = tds.length > 7 ? tds[7].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim() : '';

        list.add(InvitationItem(
          id: id,
          guestName: guestName,
          email: email,
          phone: phone,
          company: company,
          message: message,
          status: status.isNotEmpty ? status : 'Sent',
          sentAt: sentAt,
        ));
      }
    }

    return InvitationsPageData(
      invitations: list,
      totalInvitations: list.length,
    );
  }
}
