enum ReferralStatus {
  pending('Pending'),
  contacted('Contacted'),
  inDiscussion('In Discussion'),
  closedWon('Closed - Won'),
  closedLost('Closed - Lost');

  final String label;
  const ReferralStatus(this.label);

  static ReferralStatus fromString(String val) {
    for (final s in ReferralStatus.values) {
      if (s.label.toLowerCase() == val.toLowerCase() || s.name.toLowerCase() == val.toLowerCase()) {
        return s;
      }
    }
    return ReferralStatus.pending;
  }
}

class ReferralModel {
  final String id;
  final String fromMemberId;
  final String fromMemberName;
  final String fromMemberCompany;
  final String toMemberId;
  final String toMemberName;
  final String toMemberCompany;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String referralType;
  final String connectionDegree;
  final double estimatedValue;
  final double actualClosedValue;
  final ReferralStatus status;
  final String notes;
  final DateTime createdAt;

  const ReferralModel({
    required this.id,
    required this.fromMemberId,
    required this.fromMemberName,
    required this.fromMemberCompany,
    required this.toMemberId,
    required this.toMemberName,
    required this.toMemberCompany,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.referralType,
    required this.connectionDegree,
    required this.estimatedValue,
    required this.actualClosedValue,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id']?.toString() ?? '',
      fromMemberId: json['from_member_id']?.toString() ?? '',
      fromMemberName: json['from_member_name'] ?? 'WINCO Member',
      fromMemberCompany: json['from_member_company'] ?? '',
      toMemberId: json['to_member_id']?.toString() ?? '',
      toMemberName: json['to_member_name'] ?? '',
      toMemberCompany: json['to_member_company'] ?? '',
      clientName: json['client_name'] ?? json['business'] ?? '',
      clientPhone: json['client_phone'] ?? json['contact_number'] ?? '',
      clientEmail: json['client_email'] ?? '',
      referralType: json['referral_type'] ?? 'Outside',
      connectionDegree: json['connection_degree'] ?? 'Told them you would call',
      estimatedValue: (json['estimated_value'] as num?)?.toDouble() ?? 0.0,
      actualClosedValue: (json['actual_closed_value'] as num?)?.toDouble() ?? 0.0,
      status: ReferralStatus.fromString(json['status']?.toString() ?? 'Pending'),
      notes: json['notes'] ?? json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_member_id': fromMemberId,
      'from_member_name': fromMemberName,
      'from_member_company': fromMemberCompany,
      'to_member_id': toMemberId,
      'to_member_name': toMemberName,
      'to_member_company': toMemberCompany,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_email': clientEmail,
      'referral_type': referralType,
      'connection_degree': connectionDegree,
      'estimated_value': estimatedValue,
      'actual_closed_value': actualClosedValue,
      'status': status.label,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum ReferralTemperature {
  hot('Hot', '🔥 Hot'),
  warm('Warm', '🌤 Warm');

  final String value;
  final String label;
  const ReferralTemperature(this.value, this.label);

  static ReferralTemperature fromString(String val) {
    if (val.toLowerCase().contains('hot')) return ReferralTemperature.hot;
    return ReferralTemperature.warm;
  }
}

enum ReferralLiveStatus {
  openForDiscussion('Open for Discussion', 'Open for Discussion'),
  contacted('contacted', 'Contacted'),
  needSometime('not converted', 'Need Sometime'),
  cancelled('cancelled', 'Cancelled'),
  businessDone('Bussiness Done', 'Business Done');

  final String value;
  final String label;
  const ReferralLiveStatus(this.value, this.label);

  static ReferralLiveStatus fromString(String val) {
    final lower = val.toLowerCase().trim();
    if (lower.contains('business done') || lower.contains('bussiness done') || lower == 'done') {
      return ReferralLiveStatus.businessDone;
    }
    if (lower.contains('contacted')) {
      return ReferralLiveStatus.contacted;
    }
    if (lower.contains('sometime') || lower.contains('not converted')) {
      return ReferralLiveStatus.needSometime;
    }
    if (lower.contains('cancel')) {
      return ReferralLiveStatus.cancelled;
    }
    return ReferralLiveStatus.openForDiscussion;
  }
}

class ReferralItem {
  final String id;
  final String fromMemberName;
  final String fromMemberEmail;
  final String? fromMemberAvatar;
  final String toMemberName;
  final String toMemberEmail;
  final String? toMemberAvatar;
  final String referralName;
  final String contactNumber;
  final String description;
  final ReferralTemperature temperature;
  final ReferralLiveStatus status;
  final String date;
  final bool isReceived;

  const ReferralItem({
    required this.id,
    required this.fromMemberName,
    required this.fromMemberEmail,
    this.fromMemberAvatar,
    required this.toMemberName,
    required this.toMemberEmail,
    this.toMemberAvatar,
    required this.referralName,
    required this.contactNumber,
    required this.description,
    required this.temperature,
    required this.status,
    required this.date,
    required this.isReceived,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    return ReferralItem(
      id: json['id']?.toString() ?? '',
      fromMemberName: json['from_member_name']?.toString() ?? 'WINCO Member',
      fromMemberEmail: json['from_member_email']?.toString() ?? '',
      fromMemberAvatar: json['from_member_avatar']?.toString(),
      toMemberName: json['to_member_name']?.toString() ?? '',
      toMemberEmail: json['to_member_email']?.toString() ?? '',
      toMemberAvatar: json['to_member_avatar']?.toString(),
      referralName: json['business']?.toString() ?? json['client_name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? json['client_phone']?.toString() ?? '',
      description: json['description']?.toString() ?? json['notes']?.toString() ?? '',
      temperature: ReferralTemperature.fromString(json['temperature']?.toString() ?? 'Hot'),
      status: ReferralLiveStatus.fromString(json['status']?.toString() ?? 'Open for Discussion'),
      date: json['date']?.toString() ?? '',
      isReceived: json['is_received'] == true || json['type'] == 'received',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_member_name': fromMemberName,
      'from_member_email': fromMemberEmail,
      'from_member_avatar': fromMemberAvatar,
      'to_member_name': toMemberName,
      'to_member_email': toMemberEmail,
      'to_member_avatar': toMemberAvatar,
      'business': referralName,
      'contact_number': contactNumber,
      'description': description,
      'temperature': temperature.value,
      'status': status.value,
      'date': date,
      'is_received': isReceived,
    };
  }
}

class ReferralSummary {
  final int totalReferrals;
  final int receivedCount;
  final int givenCount;

  const ReferralSummary({
    required this.totalReferrals,
    required this.receivedCount,
    required this.givenCount,
  });

  factory ReferralSummary.baseline() {
    return const ReferralSummary(
      totalReferrals: 0,
      receivedCount: 0,
      givenCount: 0,
    );
  }
}

class ReferralSubmissionPayload {
  final String memberForm;
  final String toUser;
  final String business;
  final String contactNumber;
  final String description;
  final String temperature;
  final String status;

  const ReferralSubmissionPayload({
    required this.memberForm,
    required this.toUser,
    required this.business,
    required this.contactNumber,
    required this.description,
    required this.temperature,
    required this.status,
  });

  Map<String, dynamic> toFormData() {
    return {
      'member_form': memberForm,
      'to_user': toUser,
      'business': business,
      'contact_number': contactNumber,
      'description': description,
      'temperature': temperature,
      'status': status,
    };
  }
}

class ReferralStatusUpdatePayload {
  final String referralCode;
  final String status;

  const ReferralStatusUpdatePayload({
    required this.referralCode,
    required this.status,
  });

  Map<String, dynamic> toFormData() {
    return {
      'referral_code': referralCode,
      'status': status,
    };
  }
}

class ReferralPageData {
  final ReferralSummary summary;
  final List<ReferralItem> receivedReferrals;
  final List<ReferralItem> givenReferrals;

  const ReferralPageData({
    required this.summary,
    required this.receivedReferrals,
    required this.givenReferrals,
  });

  factory ReferralPageData.baseline() {
    return ReferralPageData(
      summary: ReferralSummary.baseline(),
      receivedReferrals: const [],
      givenReferrals: const [],
    );
  }

  factory ReferralPageData.fromHtml(String html) {
    int total = 0;
    int received = 0;
    int given = 0;

    final totMatch = RegExp(r'Total Referral\s*<span class="count">(\d+)</span>', caseSensitive: false).firstMatch(html);
    if (totMatch != null) {
      total = int.tryParse(totMatch.group(1)!) ?? 0;
    }

    final recMatch = RegExp(r'Received\s*<span class="badge">(\d+)</span>', caseSensitive: false).firstMatch(html);
    if (recMatch != null) {
      received = int.tryParse(recMatch.group(1)!) ?? 0;
    }

    final givMatch = RegExp(r'Given\s*<span class="badge">(\d+)</span>', caseSensitive: false).firstMatch(html);
    if (givMatch != null) {
      given = int.tryParse(givMatch.group(1)!) ?? 0;
    }

    final receivedList = <ReferralItem>[];
    final givenList = <ReferralItem>[];

    List<ReferralItem> parseCards(String blockHtml, {required bool isReceived}) {
      final list = <ReferralItem>[];
      if (blockHtml.contains('No Received Referrals') || blockHtml.contains('No Given Referrals')) {
        return list;
      }

      final cardChunks = blockHtml.split(RegExp(r'<div class="referral-card"'));
      int idx = 1;
      for (int i = 1; i < cardChunks.length; i++) {
        final chunk = cardChunks[i];

        final idMatch = RegExp(r"(?:edit_refferral_status|edit_refferral)\('([^']+)'\)").firstMatch(chunk);
        final id = idMatch?.group(1) ?? 'REF-${idx.toString().padLeft(4, '0')}';

        final nameMatches = RegExp(r'<div class="name"[^>]*>(.*?)</div>', dotAll: true).allMatches(chunk).toList();
        final names = nameMatches.map((m) => m.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim()).toList();

        final emailMatches = RegExp(r'<small[^>]*>(.*?)</small>', dotAll: true).allMatches(chunk).toList();
        final emails = emailMatches.map((m) => m.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim()).toList();

        final avatarMatches = RegExp(r'src=["''](https://[^"'']+)["'']').allMatches(chunk).toList();
        final avatars = avatarMatches.map((m) => m.group(1)!.trim()).toList();

        final businessMatch = RegExp(r'Referral Name:?\s*</div>\s*<div class="value"[^>]*>([^<]+)</div>', caseSensitive: false).firstMatch(chunk);
        final business = businessMatch?.group(1)?.trim() ?? 'Opportunity';

        final contactMatch = RegExp(r'Contact:?\s*</div>\s*<div class="value"[^>]*>([^<]+)</div>', caseSensitive: false).firstMatch(chunk);
        final contact = contactMatch?.group(1)?.trim() ?? '';

        final descMatch = RegExp(r'Details:?\s*</div>\s*<div class="value"[^>]*>([^<]+)</div>', caseSensitive: false).firstMatch(chunk);
        final desc = descMatch?.group(1)?.trim() ?? '';

        final tempMatch = RegExp(r'(🔥\s*Hot|🌤\s*Warm|Hot|Warm)', caseSensitive: false).firstMatch(chunk);
        final temp = tempMatch?.group(1) ?? 'Hot';

        final statusMatch = RegExp(r'<div class="status[^"]*"[^>]*>([^<]+)</div>', caseSensitive: false).firstMatch(chunk);
        final statusText = statusMatch?.group(1)?.trim() ?? 'Open for Discussion';

        final dateMatch = RegExp(r'<div class="date"[^>]*>([^<]+)</div>', caseSensitive: false).firstMatch(chunk) ??
            RegExp(r'\b\d{1,2}\s+[A-Za-z]{3}\s+\d{4}\b').firstMatch(chunk);
        final date = dateMatch != null ? (dateMatch.group(1)?.trim() ?? dateMatch.group(0)!.trim()) : '';

        final fromName = names.isNotEmpty ? names[0] : (isReceived ? 'Chapter Colleague' : 'Me');
        final toName = names.length > 1 ? names[1] : (isReceived ? 'Me' : 'Chapter Colleague');
        final fromEmail = emails.isNotEmpty ? emails[0] : '';
        final toEmail = emails.length > 1 ? emails[1] : '';
        final fromAvatar = avatars.isNotEmpty ? avatars[0] : null;
        final toAvatar = avatars.length > 1 ? avatars[1] : null;

        list.add(
          ReferralItem(
            id: id,
            fromMemberName: fromName,
            fromMemberEmail: fromEmail,
            fromMemberAvatar: fromAvatar,
            toMemberName: toName,
            toMemberEmail: toEmail,
            toMemberAvatar: toAvatar,
            referralName: business,
            contactNumber: contact,
            description: desc,
            temperature: ReferralTemperature.fromString(temp),
            status: ReferralLiveStatus.fromString(statusText),
            date: date,
            isReceived: isReceived,
          ),
        );
        idx++;
      }
      return list;
    }

    final receivedBoxMatch = RegExp(r'<div class="tab-content-box[^"]*" id="received">(.*?)</div>\s*<!-- GIVEN -->', dotAll: true).firstMatch(html);
    if (receivedBoxMatch != null) {
      receivedList.addAll(parseCards(receivedBoxMatch.group(1)!, isReceived: true));
    }

    final givenBoxMatch = RegExp(r'<div class="tab-content-box[^"]*" id="given">(.*?)</div>\s*</div>\s*</div>', dotAll: true).firstMatch(html);
    if (givenBoxMatch != null) {
      givenList.addAll(parseCards(givenBoxMatch.group(1)!, isReceived: false));
    }

    return ReferralPageData(
      summary: ReferralSummary(
        totalReferrals: total,
        receivedCount: received,
        givenCount: given,
      ),
      receivedReferrals: receivedList,
      givenReferrals: givenList,
    );
  }
}
