import '../../core/utils/formatters.dart';

class ChapterMemberModel {
  final String id;
  final String name;
  final String avatar;
  final String businessCategory;
  final String role;
  final int refCount;
  final String businessAmount;
  final int f2fCount;
  final int visitorsCount;
  final String contact;
  final String profileUrl;

  const ChapterMemberModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.businessCategory,
    required this.role,
    required this.refCount,
    required this.businessAmount,
    required this.f2fCount,
    required this.visitorsCount,
    required this.contact,
    required this.profileUrl,
  });

  factory ChapterMemberModel.fromJson(Map<String, dynamic> json) {
    return ChapterMemberModel(
      id: json['id']?.toString() ?? '',
      name: AppFormatters.unescapeHtml(json['name'] ?? ''),
      avatar: json['avatar'] ?? '',
      businessCategory: AppFormatters.unescapeHtml(json['business_category'] ?? json['category'] ?? ''),
      role: AppFormatters.unescapeHtml(json['role'] ?? 'member'),
      refCount: (json['ref_count'] as num?)?.toInt() ?? 0,
      businessAmount: json['business_amount'] ?? '₹0',
      f2fCount: (json['f2f_count'] as num?)?.toInt() ?? 0,
      visitorsCount: (json['visitors_count'] as num?)?.toInt() ?? 0,
      contact: json['contact'] ?? '',
      profileUrl: json['profile_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'business_category': businessCategory,
      'role': role,
      'ref_count': refCount,
      'business_amount': businessAmount,
      'f2f_count': f2fCount,
      'visitors_count': visitorsCount,
      'contact': contact,
      'profile_url': profileUrl,
    };
  }
}

class ChapterModel {
  final String id;
  final String name;
  final String city;
  final String location;
  final String status;
  final String leaderName;
  final String leaderTitle;
  final String leaderAvatar;
  final String meetingDay;
  final String meetingTime;
  final String venue;
  final String presidentName;
  final int memberCount;
  final double businessGenerated;
  final String businessFormatted;
  final int refCount;
  final int visCount;
  final int f2fCount;

  const ChapterModel({
    required this.id,
    required this.name,
    this.city = 'Bengaluru',
    required this.location,
    this.status = 'Active',
    this.leaderName = 'Not Assigned',
    this.leaderTitle = 'Chapter Leader',
    this.leaderAvatar = '',
    this.meetingDay = 'Every Alternate Thursday',
    this.meetingTime = '07:30 AM',
    this.venue = 'The Grand Conference Hall',
    this.presidentName = 'Chapter President',
    required this.memberCount,
    required this.businessGenerated,
    this.businessFormatted = '₹0',
    this.refCount = 0,
    this.visCount = 0,
    this.f2fCount = 0,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? 'Bengaluru',
      location: json['location'] ?? 'Bengaluru',
      status: json['status'] ?? 'Active',
      leaderName: json['leader_name'] ?? 'Not Assigned',
      leaderTitle: json['leader_title'] ?? 'Chapter Leader',
      leaderAvatar: json['leader_avatar'] ?? '',
      meetingDay: json['meeting_day'] ?? 'Every Alternate Thursday',
      meetingTime: json['meeting_time'] ?? '07:30 AM',
      venue: json['venue'] ?? 'The Grand Conference Hall',
      presidentName: json['president_name'] ?? (json['leader_name'] ?? 'Chapter President'),
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      businessGenerated: (json['business_generated'] as num?)?.toDouble() ?? 0.0,
      businessFormatted: json['business_formatted'] ?? '₹0',
      refCount: (json['ref_count'] as num?)?.toInt() ?? 0,
      visCount: (json['vis_count'] as num?)?.toInt() ?? 0,
      f2fCount: (json['f2f_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'location': location,
      'status': status,
      'leader_name': leaderName,
      'leader_title': leaderTitle,
      'leader_avatar': leaderAvatar,
      'meeting_day': meetingDay,
      'meeting_time': meetingTime,
      'venue': venue,
      'president_name': presidentName,
      'member_count': memberCount,
      'business_generated': businessGenerated,
      'business_formatted': businessFormatted,
      'ref_count': refCount,
      'vis_count': visCount,
      'f2f_count': f2fCount,
    };
  }
}

class MyChapterPageData {
  final ChapterModel chapter;
  final int totalMembers;
  final String totalBusiness;
  final int totalReferrals;
  final int total121s;
  final int totalVisitors;
  final int totalNotifications;
  final List<ChapterMemberModel> members;

  const MyChapterPageData({
    required this.chapter,
    required this.totalMembers,
    required this.totalBusiness,
    required this.totalReferrals,
    required this.total121s,
    required this.totalVisitors,
    required this.totalNotifications,
    required this.members,
  });

  factory MyChapterPageData.fromHtml(String html) {
    try {
      final clean = html.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

      // 1. Chapter Name and Location from chapter-card-pro
      String chapterName = 'Unassigned Chapter';
      String location = 'Unassigned';
      String status = 'Active';
      String leaderName = 'Not Assigned';
      String leaderTitle = 'Assign leader to activate insights';
      String leaderAvatar = '';
      String chapterId = '';

      final nameMatch = RegExp(r'<div class="chapter-card-pro">.*?<h4>\s*([^<]+)\s*</h4>', dotAll: true).firstMatch(clean);
      if (nameMatch != null) chapterName = AppFormatters.unescapeHtml(nameMatch.group(1)!.trim());

      final locMatch = RegExp(r'<span class="location-badge">.*?</i>\s*([^<]+)\s*</span>', dotAll: true).firstMatch(clean);
      if (locMatch != null) location = AppFormatters.unescapeHtml(locMatch.group(1)!.trim());

      final statusMatch = RegExp(r'<span class="chapter-status[^"]*">.*?</i>\s*([^<]+)\s*</span>', dotAll: true).firstMatch(clean);
      if (statusMatch != null) status = AppFormatters.unescapeHtml(statusMatch.group(1)!.trim());

      final leaderMatch = RegExp(r'<div class="leader-box">.*?<strong>\s*([^<]+)\s*</strong>', dotAll: true).firstMatch(clean);
      if (leaderMatch != null) leaderName = AppFormatters.unescapeHtml(leaderMatch.group(1)!.trim());

      final leaderTitleMatch = RegExp(r'<div class="leader-box">.*?<small>\s*([^<]+)\s*</small>', dotAll: true).firstMatch(clean);
      if (leaderTitleMatch != null) leaderTitle = AppFormatters.unescapeHtml(leaderTitleMatch.group(1)!.trim());

      final avatarMatch = RegExp(r'<div class="leader-avatar">.*?<img[^>]*src="([^"]*)"', dotAll: true).firstMatch(clean);
      if (avatarMatch != null) leaderAvatar = avatarMatch.group(1)!.trim();

      final codeMatch = RegExp(r'edit_chapter_status\("([a-zA-Z0-9]+)"\)').firstMatch(clean) ??
          RegExp(r'details/([a-zA-Z0-9]+)').firstMatch(clean);
      if (codeMatch != null) chapterId = codeMatch.group(1)!.trim();

      // 2. Overview Stat Cards
      int totalMembers = 36;
      String totalBusiness = '₹6,98,23,319';
      int totalReferrals = 311;
      int total121s = 30;
      int totalVisitors = 1;
      int totalNotifications = 273;

      final membersMatch = RegExp(r'Total Members</h6>\s*<p class="stat-value[^"]*">\s*([0-9,]+)', dotAll: true).firstMatch(clean);
      if (membersMatch != null) totalMembers = int.tryParse(membersMatch.group(1)!.replaceAll(',', '')) ?? totalMembers;

      final busMatch = RegExp(r'Total Business Done</h6>\s*<p class="stat-value[^"]*">\s*([^<]+)</p>', dotAll: true).firstMatch(clean);
      if (busMatch != null) {
        var raw = busMatch.group(1)!.trim();
        if (raw.startsWith('?')) raw = '₹${raw.substring(1)}';
        totalBusiness = raw;
      }

      final refMatch = RegExp(r'Total Referral</h6>\s*<p class="stat-value[^"]*">\s*([0-9,]+)', dotAll: true).firstMatch(clean);
      if (refMatch != null) totalReferrals = int.tryParse(refMatch.group(1)!.replaceAll(',', '')) ?? totalReferrals;

      final f2fMatch = RegExp(r'Total 121.*?</h6>\s*<p class="stat-value[^"]*">\s*([0-9,]+)', dotAll: true).firstMatch(clean);
      if (f2fMatch != null) total121s = int.tryParse(f2fMatch.group(1)!.replaceAll(',', '')) ?? total121s;

      final visMatch = RegExp(r'Total Visitors</h6>\s*<p class="stat-value[^"]*">\s*([0-9,]+)', dotAll: true).firstMatch(clean);
      if (visMatch != null) totalVisitors = int.tryParse(visMatch.group(1)!.replaceAll(',', '')) ?? totalVisitors;

      final notifMatch = RegExp(r'Notifications</h6>\s*<p class="stat-value[^"]*">\s*([0-9,]+)', dotAll: true).firstMatch(clean);
      if (notifMatch != null) totalNotifications = int.tryParse(notifMatch.group(1)!.replaceAll(',', '')) ?? totalNotifications;

      // 3. Member Roster Cards
      final List<ChapterMemberModel> memberList = [];
      final parts = clean.split('<div class="member-card">');
      for (int i = 1; i < parts.length; i++) {
        final card = parts[i];
        final idMatch = RegExp(r'details/([a-zA-Z0-9]+)').firstMatch(card);
        final id = idMatch?.group(1)?.trim() ?? 'USR$i';

        final nameMatch = RegExp(r'<h5 class="member-name">\s*([^<]+)\s*</h5>').firstMatch(card);
        final name = AppFormatters.unescapeHtml(nameMatch?.group(1)?.trim() ?? 'Member');

        String avatar = '';
        final imgMatch = RegExp(r'<img[^>]*class="[^"]*member-avatar[^"]*"[^>]*src="([^"]*)"', caseSensitive: false, dotAll: true).firstMatch(card) ??
            RegExp(r'<img[^>]*src="([^"]*)"[^>]*class="[^"]*member-avatar[^"]*"', caseSensitive: false, dotAll: true).firstMatch(card) ??
            RegExp(r'<img[^>]*src="([^"]*)"', caseSensitive: false, dotAll: true).firstMatch(card);
        if (imgMatch != null) {
          var src = imgMatch.group(1)!.trim();
          if (src.isNotEmpty && !src.contains('empty.png')) {
            if (src.startsWith('/')) src = 'https://wincoconnect.com$src';
            avatar = src;
          }
        }

        String category = '';
        final catMatch = RegExp(r'<div class="chapter-badge">.*?</i>\s*([^<]+)\s*</div>', dotAll: true).firstMatch(card);
        if (catMatch != null) category = AppFormatters.unescapeHtml(catMatch.group(1)!.trim());

        String role = 'member';
        final roleMatch = RegExp(r'Role:\s*([^<\r\n]+)').firstMatch(card);
        if (roleMatch != null) role = AppFormatters.unescapeHtml(roleMatch.group(1)!.trim());

        int ref = 0;
        final rMatch = RegExp(r'<span>Ref</span>\s*<strong>\s*([0-9,]+)\s*</strong>', dotAll: true).firstMatch(card);
        if (rMatch != null) ref = int.tryParse(rMatch.group(1)!.replaceAll(',', '')) ?? 0;

        String bus = '₹0';
        final bMatch = RegExp(r'<span>Bus</span>\s*<strong>\s*([^<]+)\s*</strong>', dotAll: true).firstMatch(card);
        if (bMatch != null) {
          var raw = bMatch.group(1)!.trim();
          if (raw.startsWith('?')) raw = '₹${raw.substring(1)}';
          bus = raw;
        }

        int f2f = 0;
        final fMatch = RegExp(r'<span>121.*?</span>\s*<strong>\s*([0-9,]+)\s*</strong>', dotAll: true).firstMatch(card);
        if (fMatch != null) f2f = int.tryParse(fMatch.group(1)!.replaceAll(',', '')) ?? 0;

        int vis = 0;
        final vMatch = RegExp(r'<span>VIS</span>\s*<strong>\s*([0-9,]+)\s*</strong>', dotAll: true).firstMatch(card);
        if (vMatch != null) vis = int.tryParse(vMatch.group(1)!.replaceAll(',', '')) ?? 0;

        String contact = '';
        final cMatch = RegExp(r'<div class="member-contact">\s*(?:<i[^>]*></i>)?\s*([^<]+)\s*</div>', dotAll: true).firstMatch(card);
        if (cMatch != null) contact = cMatch.group(1)!.trim();

        memberList.add(ChapterMemberModel(
          id: id,
          name: name,
          avatar: avatar,
          businessCategory: category,
          role: role,
          refCount: ref,
          businessAmount: bus,
          f2fCount: f2f,
          visitorsCount: vis,
          contact: contact,
          profileUrl: '/member/profile/details/$id',
        ));
      }

      final chapter = ChapterModel(
        id: chapterId,
        name: chapterName,
        location: location,
        status: status,
        leaderName: leaderName,
        leaderTitle: leaderTitle,
        leaderAvatar: leaderAvatar,
        memberCount: totalMembers,
        businessGenerated: 69823319.0,
        businessFormatted: totalBusiness,
        refCount: totalReferrals,
        f2fCount: total121s,
        visCount: totalVisitors,
      );

      return MyChapterPageData(
        chapter: chapter,
        totalMembers: totalMembers,
        totalBusiness: totalBusiness,
        totalReferrals: totalReferrals,
        total121s: total121s,
        totalVisitors: totalVisitors,
        totalNotifications: totalNotifications,
        members: memberList,
      );
    } catch (e) {
      throw FormatException('Failed to parse My Chapter HTML: $e');
    }
  }

  factory MyChapterPageData.baseline() {
    const chapter = ChapterModel(
      id: 'CHP0001',
      name: 'Winco - Jayanagar',
      city: 'Bengaluru',
      location: 'Jayanagar',
      status: 'Active',
      leaderName: 'Harri Kumar',
      leaderTitle: 'Chapter Leader',
      memberCount: 36,
      businessGenerated: 69823319.0,
      businessFormatted: '₹6,98,23,319',
      refCount: 311,
      visCount: 1,
      f2fCount: 30,
    );

    return const MyChapterPageData(
      chapter: chapter,
      totalMembers: 36,
      totalBusiness: '₹6,98,23,319',
      totalReferrals: 311,
      total121s: 30,
      totalVisitors: 1,
      totalNotifications: 273,
      members: _baselineMembers,
    );
  }

  static const List<ChapterMemberModel> _baselineMembers = [
    ChapterMemberModel(
      id: 'USR00001',
      name: 'Harri Kumar',
      avatar: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
      businessCategory: 'Growth Marketing Partner',
      role: 'member',
      refCount: 0,
      businessAmount: '₹0',
      f2fCount: 1,
      visitorsCount: 0,
      contact: '9341873532',
      profileUrl: '/member/profile/details/USR00001',
    ),
    ChapterMemberModel(
      id: 'USR00018',
      name: 'Kunal Sharma',
      avatar: 'https://wincoconnect.com/uploads/profile/empty.png',
      businessCategory: 'Home furnishings',
      role: 'member',
      refCount: 0,
      businessAmount: '₹0',
      f2fCount: 0,
      visitorsCount: 0,
      contact: 'Contact Not Provided',
      profileUrl: '/member/profile/details/USR00018',
    ),
    ChapterMemberModel(
      id: 'USR00019',
      name: 'V V Naga Tejas',
      avatar: 'https://wincoconnect.com/uploads/profile/empty.png',
      businessCategory: 'Architectural Consultant',
      role: 'member',
      refCount: 0,
      businessAmount: '₹8,700',
      f2fCount: 0,
      visitorsCount: 0,
      contact: '7019126617',
      profileUrl: '/member/profile/details/USR00019',
    ),
    ChapterMemberModel(
      id: 'USR00020',
      name: 'Thyagaraju v',
      avatar: 'https://wincoconnect.com/uploads/profile/empty.png',
      businessCategory: 'Civil Infrastructure Works',
      role: 'member',
      refCount: 5,
      businessAmount: '₹20,00,000',
      f2fCount: 0,
      visitorsCount: 0,
      contact: '9164434436',
      profileUrl: '/member/profile/details/USR00020',
    ),
    ChapterMemberModel(
      id: 'USR00049',
      name: 'Mahesh K M',
      avatar: 'https://wincoconnect.com/uploads/profile/empty.png',
      businessCategory: 'Structural Engineering',
      role: 'member',
      refCount: 38,
      businessAmount: '₹1,55,20,657',
      f2fCount: 0,
      visitorsCount: 0,
      contact: '9980007292',
      profileUrl: '/member/profile/details/USR00049',
    ),
    ChapterMemberModel(
      id: 'USR00051',
      name: 'Manjunath D',
      avatar: 'https://wincoconnect.com/uploads/profile/empty.png',
      businessCategory: 'Electrical Automation',
      role: 'member',
      refCount: 24,
      businessAmount: '₹1,27,20,903',
      f2fCount: 0,
      visitorsCount: 0,
      contact: '9900100518',
      profileUrl: '/member/profile/details/USR00051',
    ),
  ];
}

class AllChaptersPageData {
  final List<ChapterModel> chapters;
  final int totalPlatformChapters;
  final int totalPlatformMembers;
  final String totalPlatformBusiness;

  const AllChaptersPageData({
    required this.chapters,
    required this.totalPlatformChapters,
    required this.totalPlatformMembers,
    required this.totalPlatformBusiness,
  });

  factory AllChaptersPageData.fromHtml(String html) {
    try {
      final clean = html.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
      final parts = clean.split('<div class="chapter-card-pro">');
      final List<ChapterModel> chapterList = [];

      for (int i = 1; i < parts.length; i++) {
        final block = parts[i];
        final idMatch = RegExp(r'details/([a-zA-Z0-9]+)').firstMatch(block);
        final id = idMatch?.group(1)?.trim() ?? 'CHP$i';

        final nameMatch = RegExp(r'<h4>\s*([^<]+)\s*</h4>').firstMatch(block);
        final name = AppFormatters.unescapeHtml(nameMatch?.group(1)?.trim() ?? 'WINCO Chapter');

        final locMatch = RegExp(r'<span class="location-badge">.*?</i>\s*([^<]+)\s*</span>', dotAll: true).firstMatch(block);
        final location = AppFormatters.unescapeHtml(locMatch?.group(1)?.trim() ?? 'Bengaluru');

        final statusMatch = RegExp(r'<span class="chapter-status[^"]*">.*?</i>\s*([^<]+)\s*</span>', dotAll: true).firstMatch(block);
        final status = AppFormatters.unescapeHtml(statusMatch?.group(1)?.trim() ?? 'Active');

        String leader = 'Not Assigned';
        final lMatch = RegExp(r'<div class="leader-box">.*?<strong>\s*([^<]+)\s*</strong>', dotAll: true).firstMatch(block);
        if (lMatch != null) leader = AppFormatters.unescapeHtml(lMatch.group(1)!.trim());

        String leaderTitle = 'Chapter Leader';
        final ltMatch = RegExp(r'<div class="leader-box">.*?<small>\s*([^<]+)\s*</small>', dotAll: true).firstMatch(block);
        if (ltMatch != null) leaderTitle = AppFormatters.unescapeHtml(ltMatch.group(1)!.trim());

        int members = 0;
        final mMatch = RegExp(r'<span>Members</span>\s*<h3>\s*([0-9,]+)\s*</h3>', dotAll: true).firstMatch(block);
        if (mMatch != null) members = int.tryParse(mMatch.group(1)!.replaceAll(',', '')) ?? 0;

        String busStr = '₹0';
        double busVal = 0.0;
        final bMatch = RegExp(r'<span>Business</span>\s*<h3>\s*([^<]+)\s*</h3>', dotAll: true).firstMatch(block);
        if (bMatch != null) {
          var raw = bMatch.group(1)!.trim();
          if (raw.startsWith('?')) raw = '₹${raw.substring(1)}';
          busStr = raw;
          final numOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
          busVal = double.tryParse(numOnly) ?? 0.0;
        }

        int ref = 0;
        final rMatch = RegExp(r'<span>Ref\s*</span>\s*<h5>\s*([0-9,]+)\s*</h5>', dotAll: true).firstMatch(block);
        if (rMatch != null) ref = int.tryParse(rMatch.group(1)!.replaceAll(',', '')) ?? 0;

        int vis = 0;
        final vMatch = RegExp(r'<span>Vis\s*</span>\s*<h5>\s*([0-9,]+)\s*</h5>', dotAll: true).firstMatch(block);
        if (vMatch != null) vis = int.tryParse(vMatch.group(1)!.replaceAll(',', '')) ?? 0;

        int f2f = 0;
        final fMatch = RegExp(r'<span>121.*?</span>\s*<h5>\s*([0-9,]+)\s*</h5>', dotAll: true).firstMatch(block);
        if (fMatch != null) f2f = int.tryParse(fMatch.group(1)!.replaceAll(',', '')) ?? 0;

        chapterList.add(ChapterModel(
          id: id,
          name: name,
          city: 'Bengaluru',
          location: location,
          status: status,
          leaderName: leader,
          leaderTitle: leaderTitle,
          memberCount: members,
          businessGenerated: busVal,
          businessFormatted: busStr,
          refCount: ref,
          visCount: vis,
          f2fCount: f2f,
        ));
      }

      int totalMems = 0;
      for (final c in chapterList) {
        totalMems += c.memberCount;
      }

      return AllChaptersPageData(
        chapters: chapterList,
        totalPlatformChapters: chapterList.length,
        totalPlatformMembers: totalMems,
        totalPlatformBusiness: '',
      );
    } catch (e) {
      throw FormatException('Failed to parse All Chapters HTML: $e');
    }
  }

  factory AllChaptersPageData.baseline() {
    return const AllChaptersPageData(
      chapters: _baselineChapters,
      totalPlatformChapters: 6,
      totalPlatformMembers: 75,
      totalPlatformBusiness: '₹7,52,96,407',
    );
  }

  static const List<ChapterModel> _baselineChapters = [
    ChapterModel(
      id: 'CHP0001',
      name: 'Winco - Jayanagar',
      city: 'Bengaluru',
      location: 'Jayanagar',
      status: 'Active',
      leaderName: 'Harri Kumar',
      leaderTitle: 'Chapter Leader',
      memberCount: 36,
      businessGenerated: 69823319.0,
      businessFormatted: '₹6,98,23,319',
      refCount: 208,
      visCount: 1,
      f2fCount: 30,
    ),
    ChapterModel(
      id: 'CHP0002',
      name: 'Winco - JP Nagar',
      city: 'Bengaluru',
      location: 'JP Nagar',
      status: 'Active',
      leaderName: 'Not Assigned',
      leaderTitle: 'Chapter Leader',
      memberCount: 16,
      businessGenerated: 3191150.0,
      businessFormatted: '₹31,91,150',
      refCount: 70,
      visCount: 2,
      f2fCount: 6,
    ),
    ChapterModel(
      id: 'CHP0005',
      name: 'Winco - HSR Layout',
      city: 'Bengaluru',
      location: 'HSR Layout',
      status: 'Active',
      leaderName: 'Not Assigned',
      leaderTitle: 'Chapter Leader',
      memberCount: 15,
      businessGenerated: 1206438.0,
      businessFormatted: '₹12,06,438',
      refCount: 66,
      visCount: 0,
      f2fCount: 7,
    ),
    ChapterModel(
      id: 'CHP0007',
      name: 'Winco - KR Puram',
      city: 'Bengaluru',
      location: 'KR Puram',
      status: 'Active',
      leaderName: 'Not Assigned',
      leaderTitle: 'Chapter Leader',
      memberCount: 2,
      businessGenerated: 46000.0,
      businessFormatted: '₹46,000',
      refCount: 11,
      visCount: 0,
      f2fCount: 4,
    ),
    ChapterModel(
      id: 'CHP0008',
      name: 'Winco - Hebbal',
      city: 'Bengaluru',
      location: 'Hebbal',
      status: 'Active',
      leaderName: 'Not Assigned',
      leaderTitle: 'Chapter Leader',
      memberCount: 1,
      businessGenerated: 0.0,
      businessFormatted: '₹0',
      refCount: 2,
      visCount: 0,
      f2fCount: 0,
    ),
    ChapterModel(
      id: 'CHP0009',
      name: 'Winco - Yeshwantpur',
      city: 'Bengaluru',
      location: 'Yeshwantpur',
      status: 'Active',
      leaderName: 'Not Assigned',
      leaderTitle: 'Chapter Leader',
      memberCount: 5,
      businessGenerated: 1035500.0,
      businessFormatted: '₹10,35,500',
      refCount: 19,
      visCount: 0,
      f2fCount: 2,
    ),
  ];
}
