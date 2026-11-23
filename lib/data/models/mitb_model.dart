class MitbRecord {
  final String id;
  final String fromMemberName;
  final String fromMemberEmail;
  final String? fromMemberAvatar;
  final String toMemberName;
  final String toMemberEmail;
  final String? toMemberAvatar;
  final String amount;
  final double numericAmount;
  final String date;
  final String category;
  final String businessType;
  final String? description;
  final bool isReceived;

  const MitbRecord({
    required this.id,
    required this.fromMemberName,
    required this.fromMemberEmail,
    this.fromMemberAvatar,
    required this.toMemberName,
    required this.toMemberEmail,
    this.toMemberAvatar,
    required this.amount,
    required this.numericAmount,
    required this.date,
    required this.category,
    required this.businessType,
    this.description,
    required this.isReceived,
  });
}

class MitbSummary {
  final String totalRevenue;
  final String avgMemberValue;
  final int totalRecords;
  final int receivedCount;
  final int givenCount;

  const MitbSummary({
    required this.totalRevenue,
    required this.avgMemberValue,
    required this.totalRecords,
    required this.receivedCount,
    required this.givenCount,
  });

  factory MitbSummary.baseline() {
    return const MitbSummary(
      totalRevenue: '₹ 1,00,000',
      avgMemberValue: '₹ 33,333',
      totalRecords: 3,
      receivedCount: 3,
      givenCount: 0,
    );
  }
}

class MitbMemberOption {
  final String userCode;
  final String name;
  final bool isSelf;

  const MitbMemberOption({
    required this.userCode,
    required this.name,
    required this.isSelf,
  });

  factory MitbMemberOption.fromJson(Map<String, dynamic> json) {
    return MitbMemberOption(
      userCode: json['user_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isSelf: json['is_self']?.toString() == '1',
    );
  }
}

class MitbSubmissionPayload {
  final String category;
  final String toUser;
  final String amount;
  final String businessType;
  final String createdAt;
  final String description;

  const MitbSubmissionPayload({
    required this.category,
    required this.toUser,
    required this.amount,
    required this.businessType,
    required this.createdAt,
    required this.description,
  });

  Map<String, dynamic> toFormData() {
    return {
      'category': category,
      'to_user': toUser,
      'amount': amount,
      'business_type': businessType,
      'created_at': createdAt,
      'description': description,
    };
  }
}

class MitbPageData {
  final MitbSummary summary;
  final List<MitbRecord> receivedRecords;
  final List<MitbRecord> givenRecords;

  const MitbPageData({
    required this.summary,
    required this.receivedRecords,
    required this.givenRecords,
  });

  factory MitbPageData.baseline() {
    final sampleReceived = [
      const MitbRecord(
        id: 'MITB0158',
        fromMemberName: 'Harri Kumar',
        fromMemberEmail: 'harri@jobhunterr.com',
        fromMemberAvatar: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
        toMemberName: 'Harri Kumar',
        toMemberEmail: 'harri@jobhunterr.com',
        amount: '₹ 0',
        numericAmount: 0.0,
        date: '16 Nov 2026',
        category: 'My Chapter Member',
        businessType: 'New',
        isReceived: true,
      ),
      const MitbRecord(
        id: 'MITB0016',
        fromMemberName: 'Santhosha H R',
        fromMemberEmail: 'santha.hr@gmail.com',
        fromMemberAvatar: 'https://wincoconnect.com/uploads/profile/1781464255_f0d320ef676347f10aea.jpg',
        toMemberName: 'Harri Kumar',
        toMemberEmail: 'harri@jobhunterr.com',
        amount: '₹ 50,000',
        numericAmount: 50000.0,
        date: '29 Jun 2026',
        category: 'My Chapter Member',
        businessType: 'New',
        isReceived: true,
      ),
      const MitbRecord(
        id: 'MITB0015',
        fromMemberName: 'Santhosha H R',
        fromMemberEmail: 'santha.hr@gmail.com',
        fromMemberAvatar: 'https://wincoconnect.com/uploads/profile/1781464255_f0d320ef676347f10aea.jpg',
        toMemberName: 'Harri Kumar',
        toMemberEmail: 'harri@jobhunterr.com',
        amount: '₹ 50,000',
        numericAmount: 50000.0,
        date: '29 Jun 2026',
        category: 'My Chapter Member',
        businessType: 'Repeat',
        isReceived: true,
      ),
    ];

    return MitbPageData(
      summary: MitbSummary.baseline(),
      receivedRecords: sampleReceived,
      givenRecords: const [],
    );
  }

  factory MitbPageData.fromHtml(String html) {
    // 1. Parse boxes (Business Received & Business Given) first to establish verified record lists
    final boxes = html.split(RegExp(r'<div class="mitb-box"', caseSensitive: false));
    final receivedList = <MitbRecord>[];
    final givenList = <MitbRecord>[];

    for (int b = 1; b < boxes.length; b++) {
      final boxHtml = boxes[b];
      final isReceived = boxHtml.contains('Business Received');
      final rows = boxHtml.split(RegExp(r'<div class="mitb-row"', caseSensitive: false));

      for (int i = 1; i < rows.length; i++) {
        final rowContent = rows[i];

        final idMatch = RegExp(r"edit_mitb\('([^']+)'\)").firstMatch(rowContent);
        final id = idMatch?.group(1) ?? 'MITB-${isReceived ? 'REC' : 'GIV'}-$i';

        final names = RegExp(r'<div class="name"[^>]*>([^<]*)</div>').allMatches(rowContent).map((m) => m.group(1)!.trim()).toList();
        final emails = RegExp(r'<small[^>]*>([^<@]+@[^<]+)</small>', caseSensitive: false).allMatches(rowContent).map((m) => m.group(1)!.trim()).toList();
        final amounts = RegExp(r'₹\s*[\d,]+').allMatches(rowContent).map((m) => m.group(0)!.trim()).toList();
        final dates = RegExp(r'\b\d{1,2}\s+[A-Za-z]{3}\s+\d{4}\b').allMatches(rowContent).map((m) => m.group(0)!.trim()).toList();
        final avatars = RegExp(r'src=["\x27](https://[^\s"\x27]+)["\x27]').allMatches(rowContent).map((m) => m.group(1)!.trim()).toList();

        final fromName = names.isNotEmpty && names[0].isNotEmpty ? names[0] : (isReceived ? 'Harri Kumar' : 'Me');
        final toName = names.length > 1 && names[1].isNotEmpty ? names[1] : (isReceived ? 'Harri Kumar' : 'Member');
        final fromEmail = emails.isNotEmpty ? emails[0] : '';
        final toEmail = emails.length > 1 ? emails[1] : '';
        final amt = amounts.isNotEmpty ? amounts[0] : '₹ 0';
        final dt = dates.isNotEmpty ? dates[0] : '';
        final av = avatars.isNotEmpty ? avatars[0] : null;

        final record = MitbRecord(
          id: id,
          fromMemberName: fromName.replaceAll(RegExp(r'\s+'), ' '),
          fromMemberEmail: fromEmail,
          fromMemberAvatar: av,
          toMemberName: toName.replaceAll(RegExp(r'\s+'), ' '),
          toMemberEmail: toEmail,
          amount: amt,
          numericAmount: double.tryParse(amt.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
          date: dt,
          category: 'My Chapter Member',
          businessType: 'New',
          isReceived: isReceived,
        );

        if (isReceived) {
          receivedList.add(record);
        } else {
          givenList.add(record);
        }
      }
    }

    // 2. Summary Metrics extracted from server HTML with tolerant regex
    String revenue = '₹ 0';
    String avgValue = '₹ 0';
    int totalRec = receivedList.length + givenList.length;
    int receivedBadge = receivedList.length;
    int givenBadge = givenList.length;

    // Matches <h6 class="text-muted">Business Revenue</h6>\s*<h3[^>]*> ₹ 1,00,000 </h3>
    final revM = RegExp(r'Business Revenue\s*</(?:h[1-6]|small|p|div|span)>\s*<h[1-6][^>]*>\s*([^<]+)\s*</h[1-6]>', caseSensitive: false).firstMatch(html);
    if (revM != null) {
      revenue = revM.group(1)!.trim();
    } else {
      double sum = 0.0;
      for (final r in receivedList) { sum += r.numericAmount; }
      for (final g in givenList) { sum += g.numericAmount; }
      revenue = '₹ ${sum.toInt()}';
    }

    // Matches <h6 class="text-muted">Avg Member Value</h6>\s*<h3[^>]*> ₹ 33,333 </h3>
    final avgM = RegExp(r'Avg Member Value\s*</(?:h[1-6]|small|p|div|span)>\s*<h[1-6][^>]*>\s*([^<]+)\s*</h[1-6]>', caseSensitive: false).firstMatch(html);
    if (avgM != null) {
      avgValue = avgM.group(1)!.trim();
    } else if (totalRec > 0) {
      double sum = 0.0;
      for (final r in receivedList) { sum += r.numericAmount; }
      for (final g in givenList) { sum += g.numericAmount; }
      avgValue = '₹ ${(sum / totalRec).toInt()}';
    }

    // Matches <h6 class="text-muted">Total Records</h6>\s*<h3[^>]*> 3 </h3>
    final totM = RegExp(r'Total Records\s*</(?:h[1-6]|small|p|div|span)>\s*<h[1-6][^>]*>\s*(\d+)\s*</h[1-6]>', caseSensitive: false).firstMatch(html);
    if (totM != null) {
      totalRec = int.tryParse(totM.group(1)!) ?? totalRec;
    }

    // Badge counts
    final recBadgeM = RegExp(r'Business Received[\s\S]*?<span class="badge">\s*(\d+)\s*</span>', caseSensitive: false).firstMatch(html);
    if (recBadgeM != null) {
      receivedBadge = int.tryParse(recBadgeM.group(1)!) ?? receivedList.length;
    }

    final givBadgeM = RegExp(r'Business Given[\s\S]*?<span class="count-badge">\s*(\d+)\s*</span>', caseSensitive: false).firstMatch(html);
    if (givBadgeM != null) {
      givenBadge = int.tryParse(givBadgeM.group(1)!) ?? givenList.length;
    }

    return MitbPageData(
      summary: MitbSummary(
        totalRevenue: revenue,
        avgMemberValue: avgValue,
        totalRecords: totalRec,
        receivedCount: receivedBadge,
        givenCount: givenBadge,
      ),
      receivedRecords: receivedList,
      givenRecords: givenList,
    );
  }
}

