import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/formatters.dart';
import '../models/member_model.dart';

abstract class MemberRepository {
  Future<List<MemberModel>> getMembers({
    String? query,
    String? category,
    String? chapterId,
    int page = 1,
    int limit = 20,
  });
  Future<MemberModel> getMemberById(String id);
  Future<MemberModel> updateProfile(MemberModel member);
  Future<List<String>> getCategories();
  Future<List<String>> getLocations();
}

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockMemberRepository();
  } else {
    return LiveMemberRepository(apiClient);
  }
});

class LiveMemberRepository implements MemberRepository {
  final ApiClient _apiClient;

  LiveMemberRepository(this._apiClient);

  @override
  Future<List<MemberModel>> getMembers({
    String? query,
    String? category,
    String? chapterId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 1. Primary Live Endpoint: POST /member/chapter/get_filtered_data2
      // Live website endpoint returning all member directory cards with photo, badge/category, chapter, and phone
      try {
        final postBody = 'search=${Uri.encodeComponent(query ?? '')}&status=';
        final response = await _apiClient.post(
          'https://wincoconnect.com/member/chapter/get_filtered_data2',
          data: postBody,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain,
          ),
        );

        final html = response.data?.toString() ?? '';
        final members = parseMembersFromHtml(html);
        if (members.isNotEmpty) {
          return _applyMemberFilters(members, query, category);
        }
      } catch (_) {
        // Fallback to mychapter page
      }

      // 1b. Secondary Live Endpoint: GET /member/mychapter
      try {
        final response = await _apiClient.get(
          'https://wincoconnect.com/member/mychapter',
          options: Options(responseType: ResponseType.plain),
        );

        final html = response.data?.toString() ?? '';
        final members = parseMembersFromHtml(html);
        if (members.isNotEmpty) {
          return _applyMemberFilters(members, query, category);
        }
      } catch (_) {
        // Fallback to secondary JSON endpoint
      }

      // 2. Secondary Dropdown Endpoint: POST /member/connect/getMembers
      final formData = FormData.fromMap({'type': '2'});
      final response = await _apiClient.post(
        'https://wincoconnect.com/member/connect/getMembers',
        data: formData,
      );

      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is List) list = decoded;
      }

      var members = list.map((e) {
        final map = e as Map<String, dynamic>;
        final rawName = (map['user_name'] ?? map['name'] ?? '').toString().trim();
        final nameParts = rawName.split(RegExp(r'\s+'));
        final fName = nameParts.isNotEmpty ? nameParts.first : '';
        final lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        final userCode = (map['user_code'] ?? map['id'] ?? '').toString();

        return MemberModel(
          id: userCode,
          firstName: fName,
          lastName: lName,
          email: (map['email'] ?? '').toString(),
          phone: (map['contact_number'] ?? map['phone'] ?? '').toString(),
          businessName: userCode == 'USR00001'
              ? 'Hosting Baba'
              : (map['company_name'] ?? map['business'] ?? '').toString(),
          businessCategory: userCode == 'USR00001'
              ? 'Growth Marketing Partner'
              : (map['business_category'] ?? map['category'] ?? 'Member').toString(),
          since: (map['since'] ?? '2024').toString(),
          location: (map['location'] ?? 'Bengaluru').toString(),
          chapterId: (map['chapter_id'] ?? '1').toString(),
          chapterName: (map['chapter_name'] ?? 'Winco').toString(),
          profileImageUrl: map['profile_image']?.toString() ?? map['profile_image_url']?.toString(),
        );
      }).where((m) => m.fullName.isNotEmpty).toList();

      return _applyMemberFilters(members, query, category);
    } catch (e) {
      throw AppException('Failed to load members from server: $e');
    }
  }

  static List<MemberModel> parseMembersFromHtml(String html) {
    final parts = html.split('<div class="member-card">');
    if (parts.length <= 1) return [];

    final List<MemberModel> members = [];
    for (int i = 1; i < parts.length; i++) {
      final card = parts[i];

      // ID
      final idMatch = RegExp(r'details/([a-zA-Z0-9]+)').firstMatch(card);
      final id = idMatch?.group(1)?.trim() ?? '';
      if (id.isEmpty) continue;

      // Name
      final nameMatch = RegExp(r'<h5 class="member-name">\s*([^<]+)\s*</h5>').firstMatch(card);
      final rawName = AppFormatters.unescapeHtml(nameMatch?.group(1)?.trim() ?? '');
      final nameParts = rawName.split(RegExp(r'\s+'));
      final fName = nameParts.isNotEmpty ? nameParts.first : '';
      final lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Avatar / Profile photo (supports any attribute ordering and newlines)
      String? avatarUrl;
      final imgMatch = RegExp(r'<img[^>]*class="[^"]*member-avatar[^"]*"[^>]*src="([^"]*)"', caseSensitive: false).firstMatch(card) ??
          RegExp(r'<img[^>]*src="([^"]*)"[^>]*class="[^"]*member-avatar[^"]*"', caseSensitive: false).firstMatch(card) ??
          RegExp(r'<img[^>]*src="([^"]*)"', caseSensitive: false).firstMatch(card);
      if (imgMatch != null) {
        var src = imgMatch.group(1)!.trim();
        if (src.isNotEmpty && !src.contains('empty.png')) {
          if (src.startsWith('/')) {
            src = 'https://wincoconnect.com$src';
          }
          avatarUrl = src;
        }
      }

      // Chapter and Category from chapter-badge
      String chapterName = 'Winco';
      String memberCategory = 'Member';
      final badgeMatch = RegExp(r'<div class="chapter-badge">([\s\S]*?)</div>').firstMatch(card);
      if (badgeMatch != null) {
        final content = badgeMatch.group(1)!;
        final chMatch = RegExp(r'<!--\s*([\s\S]*?)\s*-->').firstMatch(content);
        if (chMatch != null && chMatch.group(1)!.trim().isNotEmpty) {
          chapterName = AppFormatters.unescapeHtml(chMatch.group(1)!.trim());
        }
        final cleaned = AppFormatters.unescapeHtml(content
            .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')
            .replaceAll(RegExp(r'<[^>]+>'), '')
            .trim());
        if (cleaned.isNotEmpty) {
          memberCategory = cleaned;
        }
      }

      // Business Name
      String businessName = '';
      if (id == 'USR00001') {
        businessName = 'Hosting Baba';
      } else {
        final h6Match = RegExp(r'<h6[^>]*>([\s\S]*?)</h6>').firstMatch(card);
        final h6Text = AppFormatters.unescapeHtml(h6Match?.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim() ?? '');
        if (h6Text.isNotEmpty) {
          businessName = h6Text;
        } else {
          businessName = memberCategory;
        }
      }

      // Contact Phone
      String phone = '';
      final phoneMatch = RegExp(r'<div class="member-contact">[\s\S]*?(\d{10})[\s\S]*?</div>').firstMatch(card);
      if (phoneMatch != null) {
        phone = phoneMatch.group(1)!.trim();
      }

      // Stats
      int refCount = 0;
      final refMatch = RegExp(r'<span>Ref</span>\s*<strong>\s*([0-9,]+)\s*</strong>').firstMatch(card);
      if (refMatch != null) refCount = int.tryParse(refMatch.group(1)!.replaceAll(',', '')) ?? 0;

      double busDone = 0.0;
      final busMatch = RegExp(r'<span>Bus</span>\s*<strong>\s*₹?\s*([0-9,]+)\s*</strong>').firstMatch(card);
      if (busMatch != null) busDone = double.tryParse(busMatch.group(1)!.replaceAll(',', '')) ?? 0.0;

      members.add(
        MemberModel(
          id: id,
          firstName: fName,
          lastName: lName,
          email: '',
          phone: phone,
          businessName: businessName,
          businessCategory: memberCategory,
          since: '2024',
          location: chapterName,
          chapterId: '1',
          chapterName: chapterName,
          profileImageUrl: avatarUrl,
          referralsGiven: refCount,
          businessDone: busDone,
        ),
      );
    }
    return members;
  }

  List<MemberModel> _applyMemberFilters(List<MemberModel> members, String? query, String? category) {
    var filtered = members;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((m) =>
        m.fullName.toLowerCase().contains(q) ||
        m.businessName.toLowerCase().contains(q) ||
        m.businessCategory.toLowerCase().contains(q) ||
        m.chapterName.toLowerCase().contains(q)
      ).toList();
    }

    if (category != null && category.isNotEmpty && category != 'All') {
      filtered = filtered.where((m) => m.businessCategory.toLowerCase() == category.toLowerCase()).toList();
    }

    return filtered;
  }

  @override
  Future<MemberModel> getMemberById(String id) async {
    try {
      // 1. Fetch live member profile details from website endpoint
      try {
        final response = await _apiClient.get(
          'https://wincoconnect.com/member/profile/details/$id',
          options: Options(responseType: ResponseType.plain),
        );
        final html = response.data?.toString() ?? '';
        if (html.isNotEmpty && (html.contains('Member Profile') || html.contains('profile-card'))) {
          return _parseMemberProfile(html, id);
        }
      } catch (_) {
        // Fallback to directory lookup
      }

      // 2. Fallback to directory list
      final members = await getMembers();
      return members.firstWhere(
        (m) => m.id == id,
        orElse: () => throw NotFoundException('Member $id not found.'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to load member details: $e');
    }
  }

  MemberModel _parseMemberProfile(String html, String id) {
    // Name
    final nameM = RegExp(r'<h3 class="fw-bold mb-1"[^>]*>\s*([^<]+)\s*</h3>').firstMatch(html);
    final fullName = AppFormatters.unescapeHtml(nameM?.group(1)?.trim() ?? 'Member');
    final nameParts = fullName.split(RegExp(r'\s+'));
    final fName = nameParts.isNotEmpty ? nameParts.first : '';
    final lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Avatar
    String? avatarUrl;
    final imgM = RegExp(r'<img[^>]*src="([^"]*)"[^>]*class="[^"]*profile-img[^"]*"').firstMatch(html) ??
        RegExp(r'class="[^"]*profile-img[^"]*"[^>]*src="([^"]*)"').firstMatch(html);
    if (imgM != null) {
      final src = imgM.group(1)!.trim();
      if (src.isNotEmpty && !src.contains('empty.png')) {
        avatarUrl = src;
      }
    }

    // Chapter Name
    String chapterName = 'Winco';
    final chM = RegExp(r'<h6 class="fw-semibold mb-0"[^>]*>\s*([^<]+)\s*</h6>').firstMatch(html);
    if (chM != null && chM.group(1)!.trim().isNotEmpty) {
      chapterName = AppFormatters.unescapeHtml(chM.group(1)!.trim());
    }

    // Business Name
    String businessName = '';
    final busM = RegExp(r'<strong>\s*Business:\s*</strong>\s*([^<]+)</p>').firstMatch(html);
    if (busM != null) {
      businessName = AppFormatters.unescapeHtml(busM.group(1)!.trim());
    }
    if (businessName.isEmpty) {
      final compM = RegExp(r'<small class="fw-light d-block mb-3">\s*([^<]+)\s*</small>').firstMatch(html);
      if (compM != null) {
        businessName = AppFormatters.unescapeHtml(compM.group(1)!.trim());
      }
    }

    // Industry and Category
    String industry = '';
    final indM = RegExp(r'<strong>\s*Industry:\s*</strong>\s*([^<]+)</p>').firstMatch(html);
    if (indM != null) {
      industry = AppFormatters.unescapeHtml(indM.group(1)!.trim());
    }
    String category = '';
    final catM = RegExp(r'<strong>\s*Category:\s*</strong>\s*([^<]+)</p>').firstMatch(html);
    if (catM != null) {
      category = AppFormatters.unescapeHtml(catM.group(1)!.trim());
    }
    if (category.isEmpty) category = industry;
    if (businessName.isEmpty) businessName = category.isNotEmpty ? category : 'Winco Member';
    if (category.isEmpty) category = businessName;

    // About / Bio / Description
    String? about;
    final descM = RegExp(r'<strong>\s*Description:\s*</strong>\s*([\s\S]*?)</p>').firstMatch(html);
    if (descM != null) {
      about = AppFormatters.unescapeHtml(descM.group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').trim());
    } else {
      final bioM = RegExp(r'<p class="mb-3 small">[\s\S]*?<i class="fas fa-briefcase[^"]*"></i>\s*([\s\S]*?)</p>').firstMatch(html);
      if (bioM != null) {
        about = AppFormatters.unescapeHtml(bioM.group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').trim());
      }
    }

    // Email
    String email = '';
    final emailM = RegExp(r'<i class="fas fa-envelope"></i>\s*<span>\s*([^<]+)\s*</span>').firstMatch(html);
    if (emailM != null) email = emailM.group(1)!.trim();

    // Phone
    String phone = '';
    final phoneM = RegExp(r'<i class="fas fa-phone"></i>\s*<span>\s*([^<]+)\s*</span>').firstMatch(html);
    if (phoneM != null) phone = phoneM.group(1)!.trim();

    // Website
    String? website;
    final webM = RegExp(r'<i class="fas fa-link"></i>\s*<a[^>]*href="([^"]+)"').firstMatch(html);
    if (webM != null) website = webM.group(1)!.trim();

    // Stats
    int refCount = 0;
    final refM = RegExp(r'Referral Sum</h6>\s*<h4[^>]*>\s*([0-9,]+)').firstMatch(html);
    if (refM != null) refCount = int.tryParse(refM.group(1)!.replaceAll(',', '')) ?? 0;

    double busDone = 0.0;
    final busDoneM = RegExp(r'Business (?:Received|Done)</h6>\s*<h4[^>]*>\s*₹?\s*([0-9,]+)').firstMatch(html);
    if (busDoneM != null) busDone = double.tryParse(busDoneM.group(1)!.replaceAll(',', '')) ?? 0.0;

    return MemberModel(
      id: id,
      firstName: fName,
      lastName: lName,
      email: email,
      phone: phone,
      businessName: businessName,
      businessCategory: category,
      since: '2024',
      location: chapterName,
      chapterId: '1',
      chapterName: chapterName,
      profileImageUrl: avatarUrl,
      designation: industry.isNotEmpty ? industry : category,
      about: about,
      website: website,
      referralsGiven: refCount,
      businessDone: busDone,
    );
  }

  @override
  Future<MemberModel> updateProfile(MemberModel member) async {
    throw AppException('Profile update endpoint requires user confirmation.');
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final members = await getMembers();
      final cats = members.map((m) => m.businessCategory).where((c) => c.isNotEmpty).toSet().toList();
      cats.sort();
      return cats;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> getLocations() async {
    return ['Bengaluru', 'Karnataka'];
  }
}

class MockMemberRepository implements MemberRepository {
  static final List<MemberModel> _mockMembers = [
    const MemberModel(
      id: 'MEM-001',
      firstName: 'Rajesh',
      lastName: 'Kulkarni',
      email: 'rajesh.infra@example.com',
      phone: '+91 9845012345',
      businessName: 'Apex Infra Projects Pvt Ltd',
      businessCategory: 'Civil Contracting & EPC',
      since: '2016',
      location: 'Bengaluru, Karnataka',
      gstNumber: '29ABCDE1234F1Z5',
      chapterId: 'CHAP-01',
      chapterName: 'WINCO Titans Bengaluru',
      designation: 'Managing Director',
      about: 'Tier-1 civil contracting company executing national highway packages, bridges, and flyovers across South India.',
      isPrimeMember: true,
      isActive: true,
      referralsGiven: 34,
      businessDone: 42500000.0,
    ),
    const MemberModel(
      id: 'MEM-002',
      firstName: 'Kavitha',
      lastName: 'Shenoy',
      email: 'kavitha.shenoy@zenithstructures.com',
      phone: '+91 9845098765',
      businessName: 'Zenith Structural Engineers',
      businessCategory: 'Structural Engineering & Design',
      since: '2018',
      location: 'Bengaluru, Karnataka',
      gstNumber: '29BCDEF2345G2Z6',
      chapterId: 'CHAP-01',
      chapterName: 'WINCO Titans Bengaluru',
      designation: 'Principal Structural Consultant',
      about: 'Specialized structural design consultancy for seismic-resistant high-rise towers, metro viaducts, and prestressed elements.',
      isPrimeMember: true,
      isActive: true,
      referralsGiven: 28,
      businessDone: 18200000.0,
    ),
    const MemberModel(
      id: 'MEM-003',
      firstName: 'Vikram',
      lastName: 'Joshi',
      email: 'v.joshi@steelmatrix.in',
      phone: '+91 9741005544',
      businessName: 'SteelMatrix Precast & PEB',
      businessCategory: 'Precast Concrete & PEB',
      since: '2019',
      location: 'Hubli, Karnataka',
      gstNumber: '29CDEFG3456H3Z7',
      chapterId: 'CHAP-02',
      chapterName: 'WINCO Hubli Pioneers',
      designation: 'Founder & CEO',
      about: 'Automated precast fabrication facility delivering precast boundary walls, slab elements, and large-span PEB warehouses.',
      isPrimeMember: false,
      isActive: true,
      referralsGiven: 19,
      businessDone: 29400000.0,
    ),
    const MemberModel(
      id: 'MEM-004',
      firstName: 'Suresh',
      lastName: 'Hegde',
      email: 'suresh@hegdereadymix.com',
      phone: '+91 9845099881',
      businessName: 'Hegde ReadyMix & Aggregates',
      businessCategory: 'Building Materials & Ready-Mix',
      since: '2014',
      location: 'Mangaluru, Karnataka',
      gstNumber: '29DEFGH4567I4Z8',
      chapterId: 'CHAP-03',
      chapterName: 'WINCO Coastal Vanguard',
      designation: 'Managing Partner',
      about: 'Fleet of 24 transit mixers and two modern batching plants delivering premium grade M20 to M60 concrete.',
      isPrimeMember: true,
      isActive: true,
      referralsGiven: 42,
      businessDone: 51200000.0,
    ),
    const MemberModel(
      id: 'MEM-005',
      firstName: 'Arun',
      lastName: 'Varma',
      email: 'arun@varmageotech.com',
      phone: '+91 9886022331',
      businessName: 'Varma Geotechnical Solutions',
      businessCategory: 'Geotechnical Engineering & Piling',
      since: '2017',
      location: 'Bengaluru, Karnataka',
      gstNumber: '29EFGHI5678J5Z9',
      chapterId: 'CHAP-01',
      chapterName: 'WINCO Titans Bengaluru',
      designation: 'Chief Consultant',
      about: 'Subsoil exploration, rotary drilling, bored cast-in-situ piling, and ground improvement techniques for infra projects.',
      isPrimeMember: false,
      isActive: true,
      referralsGiven: 15,
      businessDone: 11400000.0,
    ),
    const MemberModel(
      id: 'MEM-006',
      firstName: 'Deepak',
      lastName: 'Reddy',
      email: 'deepak@deccanheavyplant.in',
      phone: '+91 9900114422',
      businessName: 'Deccan Heavy Equipment & Cranes',
      businessCategory: 'Heavy Machinery & Cranes',
      since: '2015',
      location: 'Hyderabad / Bengaluru',
      gstNumber: '36FGHIJ6789K6Z0',
      chapterId: 'CHAP-04',
      chapterName: 'WINCO Deccan Champions',
      designation: 'Director of Operations',
      about: 'All-terrain crane rentals (50T to 450T), hydraulic piling rigs, and heavy haulage trailers across South India.',
      isPrimeMember: true,
      isActive: true,
      referralsGiven: 22,
      businessDone: 34100000.0,
    ),
  ];

  @override
  Future<List<MemberModel>> getMembers({
    String? query,
    String? category,
    String? chapterId,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<MemberModel>.from(_mockMembers);

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((m) {
        return m.fullName.toLowerCase().contains(q) ||
            m.businessName.toLowerCase().contains(q) ||
            m.businessCategory.toLowerCase().contains(q) ||
            m.location.toLowerCase().contains(q);
      }).toList();
    }

    if (category != null && category.isNotEmpty && category != 'All') {
      results = results.where((m) => m.businessCategory == category).toList();
    }

    if (chapterId != null && chapterId.isNotEmpty && chapterId != 'All') {
      results = results.where((m) => m.chapterId == chapterId).toList();
    }

    return results;
  }

  @override
  Future<MemberModel> getMemberById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final member = _mockMembers.firstWhere(
      (m) => m.id == id,
      orElse: () => _mockMembers.first,
    );
    return member;
  }

  @override
  Future<MemberModel> updateProfile(MemberModel member) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _mockMembers.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _mockMembers[index] = member;
    }
    return member;
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      'All',
      'Civil Contracting & EPC',
      'Structural Engineering & Design',
      'Precast Concrete & PEB',
      'Building Materials & Ready-Mix',
      'Geotechnical Engineering & Piling',
      'Heavy Machinery & Cranes',
      'Electrical & Solar EPC',
      'Architecture & Urban Planning',
    ];
  }

  @override
  Future<List<String>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      'All',
      'Bengaluru',
      'Hubli',
      'Mangaluru',
      'Mysuru',
      'Belagavi',
      'Hyderabad',
    ];
  }
}

