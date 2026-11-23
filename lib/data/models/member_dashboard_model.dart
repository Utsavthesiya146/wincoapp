class PersonalMetrics {
  final String businessReceived;
  final String businessGiven;
  final int? visitors;
  final int? referralsGiven;
  final int? referralsReceived;
  final int? meetings;
  final int? oneToOneByMe;
  final int? oneToOneWithMe;
  final int? notifications;
  final String profileStrength;

  const PersonalMetrics({
    required this.businessReceived,
    required this.businessGiven,
    this.visitors,
    this.referralsGiven,
    this.referralsReceived,
    this.meetings,
    this.oneToOneByMe,
    this.oneToOneWithMe,
    this.notifications,
    required this.profileStrength,
  });

  factory PersonalMetrics.baseline() {
    return const PersonalMetrics(
      businessReceived: '₹1,00,000',
      businessGiven: '₹0',
      visitors: 0,
      referralsGiven: 0,
      referralsReceived: 0,
      meetings: 1,
      oneToOneByMe: 1,
      oneToOneWithMe: 1,
      notifications: 4,
      profileStrength: 'Unavailable',
    );
  }
}

class PlatformMetrics {
  final String businessDone;
  final int visitors;
  final int referrals;
  final int meetings;
  final int oneToOnes;
  final int chapters;
  final int members;

  const PlatformMetrics({
    required this.businessDone,
    required this.visitors,
    required this.referrals,
    required this.meetings,
    required this.oneToOnes,
    required this.chapters,
    required this.members,
  });

  factory PlatformMetrics.baseline() {
    return const PlatformMetrics(
      businessDone: '₹7,77,43,407',
      visitors: 3,
      referrals: 246,
      meetings: 6,
      oneToOnes: 32,
      chapters: 6,
      members: 77,
    );
  }
}

class ChapterMetrics {
  final int? totalMembers;
  final String totalBusiness;
  final int? totalReferrals;
  final int? oneToOnes;
  final int? visitors;
  final int? notifications;

  const ChapterMetrics({
    this.totalMembers,
    required this.totalBusiness,
    this.totalReferrals,
    this.oneToOnes,
    this.visitors,
    this.notifications,
  });

  factory ChapterMetrics.baseline() {
    return const ChapterMetrics(
      totalMembers: 36,
      totalBusiness: '₹1,00,000',
      totalReferrals: 311,
      oneToOnes: 30,
      visitors: 1,
      notifications: 273,
    );
  }
}

class BusinessReportChartData {
  final List<String> labels;
  final List<double> givenData;
  final List<double> receivedData;
  final double totalGiven;
  final double totalReceived;

  const BusinessReportChartData({
    required this.labels,
    required this.givenData,
    required this.receivedData,
    required this.totalGiven,
    required this.totalReceived,
  });

  factory BusinessReportChartData.baseline() {
    return const BusinessReportChartData(
      labels: ['29 Jun', '16 Nov'],
      givenData: [0.0, 0.0],
      receivedData: [100000.0, 0.0],
      totalGiven: 0.0,
      totalReceived: 100000.0,
    );
  }

  factory BusinessReportChartData.fromHtml(String html) {
    List<String> labels = ['29 Jun', '16 Nov'];
    List<double> givenData = [0.0, 0.0];
    List<double> receivedData = [100000.0, 0.0];

    final labelsMatch = RegExp(r'(?:const|let|var)\s+labels\s*=\s*\[(.*?)\];', dotAll: true).firstMatch(html);
    if (labelsMatch != null) {
      final raw = labelsMatch.group(1)!;
      final parsed = RegExp(r'''["']([^"']+)["']''')
          .allMatches(raw)
          .map((m) => m.group(1)!.trim())
          .toList();
      if (parsed.isNotEmpty) labels = parsed;
    }

    final givenMatch = RegExp(r'(?:const|let|var)\s+givenData\s*=\s*\[(.*?)\];', dotAll: true).firstMatch(html);
    if (givenMatch != null) {
      final raw = givenMatch.group(1)!;
      final parsed = raw.split(',').map((s) => double.tryParse(s.trim()) ?? 0.0).toList();
      if (parsed.isNotEmpty) givenData = parsed;
    }

    final recMatch = RegExp(r'(?:const|let|var)\s+receivedData\s*=\s*\[(.*?)\];', dotAll: true).firstMatch(html);
    if (recMatch != null) {
      final raw = recMatch.group(1)!;
      final parsed = raw.split(',').map((s) => double.tryParse(s.trim()) ?? 0.0).toList();
      if (parsed.isNotEmpty) receivedData = parsed;
    }

    final totalGiven = givenData.fold<double>(0.0, (sum, val) => sum + val);
    final totalReceived = receivedData.fold<double>(0.0, (sum, val) => sum + val);

    return BusinessReportChartData(
      labels: labels,
      givenData: givenData,
      receivedData: receivedData,
      totalGiven: totalGiven,
      totalReceived: totalReceived,
    );
  }
}

class RecentMeetingItem {
  final String number;
  final String date;
  final String time;
  final String event;
  final String chapter;

  const RecentMeetingItem({
    required this.number,
    required this.date,
    required this.time,
    required this.event,
    required this.chapter,
  });
}

class MemberDashboardData {
  final String memberName;
  final String memberCode;
  final String chapterName;
  final String activeFilter;
  final PersonalMetrics personal;
  final PlatformMetrics platform;
  final ChapterMetrics chapter;
  final BusinessReportChartData chart;
  final List<RecentMeetingItem> recentMeetings;

  const MemberDashboardData({
    required this.memberName,
    required this.memberCode,
    required this.chapterName,
    required this.activeFilter,
    required this.personal,
    required this.platform,
    required this.chapter,
    required this.chart,
    required this.recentMeetings,
  });

  factory MemberDashboardData.baseline() {
    return MemberDashboardData(
      memberName: 'Harri Kumar',
      memberCode: 'USR00001',
      chapterName: 'Unassigned',
      activeFilter: 'Lifetime',
      personal: PersonalMetrics.baseline(),
      platform: PlatformMetrics.baseline(),
      chapter: ChapterMetrics.baseline(),
      chart: BusinessReportChartData.baseline(),
      recentMeetings: const [
        RecentMeetingItem(
          number: '#1',
          date: '24 Jul 2026',
          time: '09:45 AM',
          event: 'Project Collaboration',
          chapter: 'Unassigned',
        ),
      ],
    );
  }

  factory MemberDashboardData.fromHtml(
    String html, {
    String filter = 'Lifetime',
    String? chapterName,
  }) {
    // 1. Member Name
    String memberName = '';
    final nameMatch = RegExp(r'Hello\s+([^\n<]+)', caseSensitive: false).firstMatch(html);
    if (nameMatch != null) {
      memberName = nameMatch.group(1)!.trim();
    }

    // 2. Member Code
    String memberCode = '';
    final codeMatch = RegExp(r'\b(USR\d+)\b').firstMatch(html);
    if (codeMatch != null) {
      memberCode = codeMatch.group(1)!;
    }

    // 3. Chapter Name (Priority: passed chapterName > HTML parsed > 'Unassigned')
    String resolvedChapter = chapterName?.trim() ?? '';
    if (resolvedChapter.isEmpty) {
      final chMatch = RegExp(r'Chapter\s*:\s*</span>\s*<span>([^<]+)</span>', caseSensitive: false).firstMatch(html);
      if (chMatch != null) {
        resolvedChapter = chMatch.group(1)!.trim();
      }
    }
    if (resolvedChapter.isEmpty) {
      resolvedChapter = 'Unassigned';
    }

    // 4. Platform Metrics (from ticker/marquee)
    String businessDone = '₹0';
    int platformVisitors = 0;
    int platformReferrals = 0;
    int platformMeetings = 0;
    int platform121s = 0;
    int platformChapters = 0;
    int platformMembers = 0;

    final bdMatch = RegExp(r'Business Done:\s*([^&|<]+)', caseSensitive: false).firstMatch(html);
    if (bdMatch != null) businessDone = bdMatch.group(1)!.trim();

    final pvMatch = RegExp(r'Visitors:\s*(\d+)', caseSensitive: false).firstMatch(html);
    if (pvMatch != null) platformVisitors = int.tryParse(pvMatch.group(1)!) ?? 0;

    final prMatch = RegExp(r'Referral:\s*(\d+)', caseSensitive: false).firstMatch(html);
    if (prMatch != null) platformReferrals = int.tryParse(prMatch.group(1)!) ?? 0;

    final pmMatch = RegExp(r'Meetings:\s*(\d+)', caseSensitive: false).firstMatch(html);
    if (pmMatch != null) platformMeetings = int.tryParse(pmMatch.group(1)!) ?? 0;

    final p121Match = RegExp(r"121's Initiated:\s*(\d+)", caseSensitive: false).firstMatch(html);
    if (p121Match != null) platform121s = int.tryParse(p121Match.group(1)!) ?? 0;

    final pchMatch = RegExp(r'Chapters:\s*(\d+)', caseSensitive: false).firstMatch(html);
    if (pchMatch != null) platformChapters = int.tryParse(pchMatch.group(1)!) ?? 0;

    final pmemMatch = RegExp(r'Members:\s*(\d+)', caseSensitive: false).firstMatch(html);
    if (pmemMatch != null) platformMembers = int.tryParse(pmemMatch.group(1)!) ?? 0;

    // 5. Personal Metrics
    String bReceived = '₹0';
    String bGiven = '₹0';
    int? myVisitors;
    int? myRefGiven;
    int? myRefRec;
    int? myMeetings;
    int? my121Me;
    int? my121With;
    int? notifCount;
    String profStr = 'Unavailable';

    final brMatch = RegExp(r'Business Received</small>\s*<h5[^>]*>([^<]+)</h5>', caseSensitive: false).firstMatch(html);
    if (brMatch != null) bReceived = brMatch.group(1)!.trim();

    final bgMatch = RegExp(r'Business Given</small>\s*<h5[^>]*>([^<]+)</h5>', caseSensitive: false).firstMatch(html);
    if (bgMatch != null) bGiven = bgMatch.group(1)!.trim();

    final vMatch = RegExp(r'Visitors</small>\s*<h5[^>]*>(\d+)</h5>', caseSensitive: false).firstMatch(html);
    if (vMatch != null) myVisitors = int.tryParse(vMatch.group(1)!);

    final rgMatch = RegExp(r'Referral Given</small>\s*<h5[^>]*>(\d+)</h5>', caseSensitive: false).firstMatch(html);
    if (rgMatch != null) myRefGiven = int.tryParse(rgMatch.group(1)!);

    final rrMatch = RegExp(r'Referral Received</small>\s*<h5[^>]*>(\d+)</h5>', caseSensitive: false).firstMatch(html);
    if (rrMatch != null) myRefRec = int.tryParse(rrMatch.group(1)!);

    final mmMatch = RegExp(r'Meetings</small>\s*<h5[^>]*>(\d+)</h5>', caseSensitive: false).firstMatch(html);
    if (mmMatch != null) myMeetings = int.tryParse(mmMatch.group(1)!);

    // Matches both '<b style="...">121</b> Initiated By Me' and plain '121 Initiated By Me'
    final m121MeMatch = RegExp(r'121(?:<[^>]+>)*\s*Initiated By Me</small>\s*<h5[^>]*>(\d+)</h5>', caseSensitive: false).firstMatch(html);
    if (m121MeMatch != null) my121Me = int.tryParse(m121MeMatch.group(1)!);

    // Matches both '<b style="...">121</b> Initiated With Me' and plain '121 Initiated With Me'
    final m121WithMatch = RegExp(r'121(?:<[^>]+>)*\s*Initiated With Me</small>\s*<h5[^>]*>(\d+)</h5>', caseSensitive: false).firstMatch(html);
    if (m121WithMatch != null) my121With = int.tryParse(m121WithMatch.group(1)!);

    final nMatch = RegExp(r'Notifications\s*(\d+)', caseSensitive: false).firstMatch(html);
    if (nMatch != null) notifCount = int.tryParse(nMatch.group(1)!);

    // Profile strength: Check dynamic 'let target = (\d+);' first, then html text match
    final targetMatch = RegExp(r'let\s+target\s*=\s*(\d+);').firstMatch(html);
    if (targetMatch != null) {
      profStr = '${targetMatch.group(1)}%';
    } else {
      final psMatch = RegExp(r'Profile\s*Strength[^\d]*(\d+)\s*%', caseSensitive: false).firstMatch(html);
      if (psMatch != null) {
        profStr = '${psMatch.group(1)}%';
      }
    }

    // 6. Chapter Metrics
    int? chMembers;
    String chBusiness = '₹0';
    int? chRef;
    int? ch121;
    int? chVis;
    int? chNotif;

    final chMemMatch = RegExp(r'Total Members\s*</span>\s*<h3[^>]*>(\d+)</h3>', caseSensitive: false).firstMatch(html);
    if (chMemMatch != null) chMembers = int.tryParse(chMemMatch.group(1)!);

    final chBizMatch = RegExp(r'Total Business\s*</span>\s*<h3[^>]*>([^<]+)</h3>', caseSensitive: false).firstMatch(html);
    if (chBizMatch != null) chBusiness = chBizMatch.group(1)!.trim();

    final chRefMatch = RegExp(r'Total Referral\s*</span>\s*<h3[^>]*>(\d+)</h3>', caseSensitive: false).firstMatch(html);
    if (chRefMatch != null) chRef = int.tryParse(chRefMatch.group(1)!);

    // Matches both '<span><b style="...">121</b> Initiated</span>' and plain '<span>121 Initiated</span>'
    final ch121Match = RegExp(r'121(?:<[^>]+>)*\s*Initiated\s*</span>\s*<h3[^>]*>(\d+)</h3>', caseSensitive: false).firstMatch(html);
    if (ch121Match != null) ch121 = int.tryParse(ch121Match.group(1)!);

    final chVisMatch = RegExp(r'Visitors\s*</span>\s*<h3[^>]*>(\d+)</h3>', caseSensitive: false).firstMatch(html);
    if (chVisMatch != null) chVis = int.tryParse(chVisMatch.group(1)!);

    final chNotifMatch = RegExp(r'Notifications\s*</span>\s*<h3[^>]*>(\d+)</h3>', caseSensitive: false).firstMatch(html);
    if (chNotifMatch != null) chNotif = int.tryParse(chNotifMatch.group(1)!);

    // 7. Recent Meetings
    final meetingsList = <RecentMeetingItem>[];
    final meetingMatches = RegExp(
      r'<div class="meeting-row">([\s\S]*?)(?=<div class="meeting-row"|</body>|$)',
      caseSensitive: false,
    ).allMatches(html);
    for (final mm in meetingMatches) {
      final block = mm.group(1) ?? '';
      final numM = RegExp(r'#\d+').firstMatch(block);
      final dateM = RegExp(r'<b>([^<]+)</b>').firstMatch(block);
      final smalls = RegExp(r'<small[^>]*class="[^"]*text-muted[^"]*"[^>]*>\s*([^<]+)\s*</small>').allMatches(block).map((m) => m.group(1)!.trim()).toList();
      final eventM = RegExp(r'<div class="fw-semibold">\s*([^<]+)\s*</div>').firstMatch(block);

      final time = smalls.isNotEmpty ? smalls[0] : '09:45 AM';
      final chapter = smalls.length > 1 ? smalls[1] : resolvedChapter;

      meetingsList.add(
        RecentMeetingItem(
          number: numM?.group(0) ?? '#1',
          date: dateM?.group(1)?.trim() ?? '24 Jul 2026',
          time: time,
          event: eventM?.group(1)?.trim() ?? '',
          chapter: chapter,
        ),
      );
    }

    // 8. Business Report Dual-Series Chart Data
    final chartData = BusinessReportChartData.fromHtml(html);

    return MemberDashboardData(
      memberName: memberName,
      memberCode: memberCode,
      chapterName: resolvedChapter,
      activeFilter: filter,
      personal: PersonalMetrics(
        businessReceived: bReceived,
        businessGiven: bGiven,
        visitors: myVisitors,
        referralsGiven: myRefGiven,
        referralsReceived: myRefRec,
        meetings: myMeetings,
        oneToOneByMe: my121Me,
        oneToOneWithMe: my121With,
        notifications: notifCount,
        profileStrength: profStr,
      ),
      platform: PlatformMetrics(
        businessDone: businessDone,
        visitors: platformVisitors,
        referrals: platformReferrals,
        meetings: platformMeetings,
        oneToOnes: platform121s,
        chapters: platformChapters,
        members: platformMembers,
      ),
      chapter: ChapterMetrics(
        totalMembers: chMembers,
        totalBusiness: chBusiness,
        totalReferrals: chRef,
        oneToOnes: ch121,
        visitors: chVis,
        notifications: chNotif,
      ),
      chart: chartData,
      recentMeetings: meetingsList,
    );
  }
}

