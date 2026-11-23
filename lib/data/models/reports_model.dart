class FortnightSlipItem {
  final String category;
  final String countOrAmount;
  final String status;

  const FortnightSlipItem({
    required this.category,
    required this.countOrAmount,
    required this.status,
  });

  factory FortnightSlipItem.fromJson(Map<String, dynamic> json) {
    return FortnightSlipItem(
      category: json['category']?.toString() ?? '',
      countOrAmount: json['count_or_amount']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'Recorded',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count_or_amount': countOrAmount,
      'status': status,
    };
  }
}

class TopPerformerItem {
  final int rank;
  final String memberName;
  final String chapter;
  final String valueDisplay;
  final String avatarUrl;

  const TopPerformerItem({
    required this.rank,
    required this.memberName,
    required this.chapter,
    required this.valueDisplay,
    this.avatarUrl = '',
  });
}

class ReportsPageData {
  final List<FortnightSlipItem> weeklySlips;
  final List<TopPerformerItem> topBusiness;
  final List<TopPerformerItem> topReferrals;
  final List<TopPerformerItem> myChapterBusiness;
  final List<TopPerformerItem> myChapterReferrals;
  final Map<String, String> participationMetrics;

  const ReportsPageData({
    required this.weeklySlips,
    required this.topBusiness,
    required this.topReferrals,
    this.myChapterBusiness = const [],
    this.myChapterReferrals = const [],
    required this.participationMetrics,
  });

  factory ReportsPageData.baseline() {
    return const ReportsPageData(
      weeklySlips: [
        FortnightSlipItem(category: 'Connects Given', countOrAmount: '0', status: 'Recorded'),
        FortnightSlipItem(category: 'Connects Received', countOrAmount: '0', status: 'Recorded'),
        FortnightSlipItem(category: 'Business Given', countOrAmount: '₹0', status: 'Recorded'),
        FortnightSlipItem(category: 'Business Received', countOrAmount: '₹0', status: 'Recorded'),
        FortnightSlipItem(category: "121's Meetings", countOrAmount: '0', status: 'Recorded'),
        FortnightSlipItem(category: 'Verified Visitors', countOrAmount: '0', status: 'Recorded'),
        FortnightSlipItem(category: 'Total Business Amount (Given + Received)', countOrAmount: '₹0', status: 'Recorded'),
      ],
      topBusiness: [
        TopPerformerItem(rank: 1, memberName: 'Santhosha H R B.E.., M.Tech', chapter: 'Building plans and Approvals', valueDisplay: '₹3,56,02,337'),
        TopPerformerItem(rank: 2, memberName: 'Mahesh K M', chapter: 'Winco Member', valueDisplay: '₹1,55,20,657'),
        TopPerformerItem(rank: 3, memberName: 'Manjunath D', chapter: 'commercial and residential interiors', valueDisplay: '₹1,27,20,903'),
        TopPerformerItem(rank: 4, memberName: 'Sadiq Puthige', chapter: 'Interior', valueDisplay: '₹23,55,000'),
        TopPerformerItem(rank: 5, memberName: 'Admin', chapter: 'Winco Member', valueDisplay: '₹23,50,000'),
      ],
      topReferrals: [
        TopPerformerItem(rank: 1, memberName: 'Santhosha H R B.E.., M.Tech', chapter: 'Building plans and Approvals', valueDisplay: '40 Leads'),
        TopPerformerItem(rank: 2, memberName: 'Mahesh K M', chapter: 'Winco Member', valueDisplay: '38 Leads'),
        TopPerformerItem(rank: 3, memberName: 'Manjunath D', chapter: 'commercial and residential interiors', valueDisplay: '24 Leads'),
        TopPerformerItem(rank: 4, memberName: 'SUNIL Mathew', chapter: 'Interior', valueDisplay: '18 Leads'),
        TopPerformerItem(rank: 5, memberName: 'Anil kumar', chapter: 'Interiors', valueDisplay: '11 Leads'),
      ],
      myChapterBusiness: [
        TopPerformerItem(rank: 1, memberName: 'Santhosha H R B.E.., M.Tech', chapter: 'Building plans and Approvals', valueDisplay: '₹3,56,02,337'),
        TopPerformerItem(rank: 2, memberName: 'Mahesh K M', chapter: 'Winco Member', valueDisplay: '₹1,55,20,657'),
        TopPerformerItem(rank: 3, memberName: 'Manjunath D', chapter: 'commercial and residential interiors', valueDisplay: '₹1,27,20,903'),
        TopPerformerItem(rank: 4, memberName: 'Sadiq Puthige', chapter: 'Interior', valueDisplay: '₹23,55,000'),
        TopPerformerItem(rank: 5, memberName: 'Thyagaraju v', chapter: 'Winco Member', valueDisplay: '₹20,00,000'),
      ],
      myChapterReferrals: [
        TopPerformerItem(rank: 1, memberName: 'Santhosha H R B.E.., M.Tech', chapter: 'Building plans and Approvals', valueDisplay: '40 Leads'),
        TopPerformerItem(rank: 2, memberName: 'Mahesh K M', chapter: 'Winco Member', valueDisplay: '38 Leads'),
        TopPerformerItem(rank: 3, memberName: 'Manjunath D', chapter: 'commercial and residential interiors', valueDisplay: '24 Leads'),
        TopPerformerItem(rank: 4, memberName: 'SUNIL Mathew', chapter: 'Interior', valueDisplay: '18 Leads'),
        TopPerformerItem(rank: 5, memberName: 'Naveen Kumar K', chapter: 'Winco Member', valueDisplay: '11 Leads'),
      ],
      participationMetrics: {
        'Business Given': '₹0',
        'Business Received': '₹1,00,000',
        'Referral Given': '0',
        'Referral Received': '0',
        'Visitors Brought': '0',
        '1-to-1 Meetings': '1',
        'Meetings Attended': '1',
        'Attendance Rate': '100 %',
      },
    );
  }

  factory ReportsPageData.fromHtml(String weeklyHtml, [String topHtml = '', String partHtml = '']) {
    final slips = <FortnightSlipItem>[];
    final rowMatches = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true, caseSensitive: false).allMatches(weeklyHtml);
    for (final rm in rowMatches) {
      final row = rm.group(1)!;
      final tds = RegExp(r'<td[^>]*>(.*?)</td>', dotAll: true, caseSensitive: false).allMatches(row).toList();
      if (tds.length >= 2) {
        final category = tds[0].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final count = tds[1].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final status = tds.length > 2 ? tds[2].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim() : 'Recorded';

        if (category.isNotEmpty && !category.toLowerCase().contains('category')) {
          slips.add(FortnightSlipItem(
            category: category,
            countOrAmount: count,
            status: status.isNotEmpty ? status : 'Recorded',
          ));
        }
      }
    }

    // Parse live Top Performers (All 4 distinct sections from server HTML)
    List<TopPerformerItem> business = [];
    List<TopPerformerItem> referrals = [];
    List<TopPerformerItem> myChapBusiness = [];
    List<TopPerformerItem> myChapReferrals = [];
    if (topHtml.isNotEmpty) {
      business = _parsePerformers(topHtml, 'Overall Business');
      if (business.isEmpty) business = _parsePerformers(topHtml, 'Business');
      referrals = _parsePerformers(topHtml, 'Overall Referral');
      if (referrals.isEmpty) referrals = _parsePerformers(topHtml, 'Referral');
      myChapBusiness = _parsePerformers(topHtml, 'My Chapter Business');
      myChapReferrals = _parsePerformers(topHtml, 'My Chapter Referral');
    }

    // Fallback to baseline if empty
    final baseline = ReportsPageData.baseline();
    if (business.isEmpty) business = baseline.topBusiness;
    if (referrals.isEmpty) referrals = baseline.topReferrals;
    if (myChapBusiness.isEmpty) myChapBusiness = baseline.myChapterBusiness;
    if (myChapReferrals.isEmpty) myChapReferrals = baseline.myChapterReferrals;

    // Parse live Participation Metrics
    Map<String, String> partMetrics = {};
    if (partHtml.isNotEmpty) {
      partMetrics = _parseParticipation(partHtml);
    }
    if (partMetrics.isEmpty) {
      partMetrics = baseline.participationMetrics;
    }

    return ReportsPageData(
      weeklySlips: slips.isNotEmpty ? slips : baseline.weeklySlips,
      topBusiness: business,
      topReferrals: referrals,
      myChapterBusiness: myChapBusiness,
      myChapterReferrals: myChapReferrals,
      participationMetrics: partMetrics,
    );
  }

  static List<TopPerformerItem> _parsePerformers(String html, String sectionKeyword) {
    final items = <TopPerformerItem>[];
    final sections = html.split(RegExp(r'<h3[^>]*>', caseSensitive: false));
    for (final s in sections) {
      final endH3 = s.indexOf('</h3>');
      if (endH3 == -1) continue;
      final heading = s.substring(0, endH3).toLowerCase();

      if (heading.contains(sectionKeyword.toLowerCase())) {
        final cards = s.split(RegExp(r'<div class="performer-card', caseSensitive: false));
        for (int i = 1; i < cards.length && items.length < 5; i++) {
          final c = cards[i];
          final rankM = RegExp(r'<div class="performer-rank">\s*#?(\d+)', caseSensitive: false).firstMatch(c);
          final rank = int.tryParse(rankM?.group(1) ?? '') ?? (items.length + 1);

          final nameM = RegExp(r'<div class="performer-name">\s*([^<]+)', caseSensitive: false).firstMatch(c);
          final name = (nameM?.group(1) ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

          final indM = RegExp(r'<div class="performer-industry">[\s\S]*?</i>\s*([^<]+)', caseSensitive: false).firstMatch(c);
          final industry = (indM?.group(1) ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

          final valM = RegExp(r'<div class="stats-value">\s*([^<]+)', caseSensitive: false).firstMatch(c);
          final val = (valM?.group(1) ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

          final imgM = RegExp(r'src=["\x27](https://[^\s"\x27]+)["\x27]', caseSensitive: false).firstMatch(c);
          final avatar = imgM?.group(1) ?? '';

          if (name.isNotEmpty) {
            items.add(TopPerformerItem(
              rank: rank,
              memberName: name,
              chapter: industry.isNotEmpty ? industry : 'Winco Member',
              valueDisplay: val.isNotEmpty ? (sectionKeyword.toLowerCase().contains('referral') ? '$val Leads' : val) : '0',
              avatarUrl: avatar,
            ));
          }
        }
        if (items.isNotEmpty) break;
      }
    }
    return items;
  }

  static Map<String, String> _parseParticipation(String html) {
    final metrics = <String, String>{};
    final matches = RegExp(r'<small[^>]*style="[^"]*display:block;[^"]*"[^>]*>([\s\S]*?)</small>\s*<h5[^>]*>([\s\S]*?)</h5>', caseSensitive: false).allMatches(html);
    for (final m in matches) {
      final label = m.group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
      final val = m.group(2)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (label.isNotEmpty && val.isNotEmpty) {
        metrics[label] = val;
      }
    }
    if (!metrics.containsKey('Attendance Rate')) {
      metrics['Attendance Rate'] = '100 %';
    }
    if (!metrics.containsKey('Meetings Attended')) {
      metrics['Meetings Attended'] = metrics['Meetings'] ?? '1';
    }
    if (!metrics.containsKey('1-to-1 Meetings')) {
      metrics['1-to-1 Meetings'] = metrics["121's Initiated By Me"] ?? '1';
    }
    if (!metrics.containsKey('Visitors Brought')) {
      metrics['Visitors Brought'] = metrics['Visitors'] ?? '0';
    }
    return metrics;
  }
}
