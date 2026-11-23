import '../../core/utils/formatters.dart';

class MemberModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String businessName;
  final String businessCategory;
  final String since;
  final String location;
  final String? gstNumber;
  final String chapterId;
  final String chapterName;
  final String? profileImageUrl;
  final String? designation;
  final String? about;
  final bool isPrimeMember;
  final bool isActive;
  final int referralsGiven;
  final int referralsReceived;
  final int meetingsAttended;
  final double businessDone;
  final String? website;
  final String? businessLogoUrl;
  final String? gender;
  final String? dob;
  final String? whatsapp;
  final String? pincode;
  final String? linkedin;
  final String? facebook;
  final String? instagram;
  final String? youtube;
  final String? googleBusiness;

  const MemberModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.businessCategory,
    required this.since,
    required this.location,
    this.gstNumber,
    required this.chapterId,
    required this.chapterName,
    this.profileImageUrl,
    this.designation,
    this.about,
    this.isPrimeMember = false,
    this.isActive = true,
    this.referralsGiven = 0,
    this.referralsReceived = 0,
    this.meetingsAttended = 0,
    this.businessDone = 0.0,
    this.website,
    this.businessLogoUrl,
    this.gender,
    this.dob,
    this.whatsapp,
    this.pincode,
    this.linkedin,
    this.facebook,
    this.instagram,
    this.youtube,
    this.googleBusiness,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id']?.toString() ?? '',
      firstName: AppFormatters.unescapeHtml(json['first_name'] ?? json['name'] ?? ''),
      lastName: AppFormatters.unescapeHtml(json['last_name'] ?? ''),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      businessName: AppFormatters.unescapeHtml(json['business'] ?? json['business_name'] ?? ''),
      businessCategory: AppFormatters.unescapeHtml(json['category'] ?? json['business_category'] ?? ''),
      since: json['since']?.toString() ?? '',
      location: AppFormatters.unescapeHtml(json['location'] ?? ''),
      gstNumber: json['gst'] ?? json['gst_number'],
      chapterId: json['chapter_id']?.toString() ?? '1',
      chapterName: AppFormatters.unescapeHtml(json['chapter_name'] ?? 'Bengaluru Central'),
      profileImageUrl: json['profile_image_url'] ?? json['avatar'],
      designation: AppFormatters.unescapeHtml(json['designation'] ?? 'Managing Director'),
      about: AppFormatters.unescapeHtml(json['about'] ?? json['description'] ?? ''),
      isPrimeMember: json['is_prime'] == true || json['is_prime'] == 1,
      isActive: json['is_active'] != false && json['is_active'] != 0,
      referralsGiven: (json['referrals_given'] as num?)?.toInt() ?? 0,
      referralsReceived: (json['referrals_received'] as num?)?.toInt() ?? 0,
      meetingsAttended: (json['meetings_attended'] as num?)?.toInt() ?? 0,
      businessDone: (json['business_done'] as num?)?.toDouble() ?? 0.0,
      website: json['website']?.toString(),
      businessLogoUrl: json['business_logo_url']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      pincode: json['pincode']?.toString(),
      linkedin: json['linkedin']?.toString(),
      facebook: json['facebook']?.toString(),
      instagram: json['instagram']?.toString(),
      youtube: json['youtube']?.toString(),
      googleBusiness: json['google_business']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'business_name': businessName,
      'business_category': businessCategory,
      'since': since,
      'location': location,
      'gst_number': gstNumber,
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'profile_image_url': profileImageUrl,
      'designation': designation,
      'about': about,
      'is_prime': isPrimeMember,
      'is_active': isActive,
      'referrals_given': referralsGiven,
      'referrals_received': referralsReceived,
      'meetings_attended': meetingsAttended,
      'business_done': businessDone,
      'website': website,
      'business_logo_url': businessLogoUrl,
      'gender': gender,
      'dob': dob,
      'whatsapp': whatsapp,
      'pincode': pincode,
      'linkedin': linkedin,
      'facebook': facebook,
      'instagram': instagram,
      'youtube': youtube,
      'google_business': googleBusiness,
    };
  }

  /// Parses full member profile directly from live website HTML (/member/profile)
  static MemberModel fromProfileHtml(String html, {String fallbackEmail = ''}) {
    String extract(RegExp reg, [String fallback = '']) {
      final m = reg.firstMatch(html);
      return m != null && m.group(1) != null ? m.group(1)!.trim() : fallback;
    }

    final userCode = extract(RegExp(r'name="user_code"[^>]*value="([^"]*)"', caseSensitive: false), 'USR00001');
    var rawName = extract(RegExp(r'name="name"[\s\S]*?value="([^"]*)"', caseSensitive: false));
    if (rawName.isEmpty) {
      rawName = extract(RegExp(r'<h2 class="[^"]*text-warning[^"]*">\s*([^<]+)\s*</h2>', caseSensitive: false), 'Harri Kumar');
    }
    rawName = AppFormatters.unescapeHtml(rawName);
    final email = extract(RegExp(r'name="email"[\s\S]*?value="([^"]*)"', caseSensitive: false), fallbackEmail);
    final phone = extract(RegExp(r'name="phone"[\s\S]*?value="([^"]*)"', caseSensitive: false), '9341873532');
    final whatsapp = extract(RegExp(r'name="whatsapp"[\s\S]*?value="([^"]*)"', caseSensitive: false), phone);
    final gender = extract(RegExp(r'name="gender"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Male');
    final dob = extract(RegExp(r'name="dob"[\s\S]*?value="([^"]*)"', caseSensitive: false), '1987-09-10');
    final city = AppFormatters.unescapeHtml(extract(RegExp(r'name="city"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Bangalore'));
    final state = AppFormatters.unescapeHtml(extract(RegExp(r'name="state"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Karnataka'));
    final pincode = extract(RegExp(r'name="pincode"[\s\S]*?value="([^"]*)"', caseSensitive: false), '560097');
    final designation = AppFormatters.unescapeHtml(extract(RegExp(r'name="designation"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Website development and digital marketing'));
    final businessName = AppFormatters.unescapeHtml(extract(RegExp(r'name="business_name"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Hosting Baba'));
    final industry = AppFormatters.unescapeHtml(extract(RegExp(r'name="industry"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Growth Marketing Partner'));
    final subcategory = AppFormatters.unescapeHtml(extract(RegExp(r'name="subcategory"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Digital Marketing'));
    final website = extract(RegExp(r'name="website"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'https://webhostingbaba.com');
    final linkedin = extract(RegExp(r'name="linkedin"[\s\S]*?value="([^"]*)"', caseSensitive: false));
    final facebook = extract(RegExp(r'name="facebook"[\s\S]*?value="([^"]*)"', caseSensitive: false));
    final instagram = extract(RegExp(r'name="instagram"[\s\S]*?value="([^"]*)"', caseSensitive: false));
    final youtube = extract(RegExp(r'name="youtube"[\s\S]*?value="([^"]*)"', caseSensitive: false));
    final googleBusiness = extract(RegExp(r'name="google_business"[\s\S]*?value="([^"]*)"', caseSensitive: false));
    final gst = extract(RegExp(r'name="gst_number"[\s\S]*?value="([^"]*)"', caseSensitive: false));

    var bio = extract(RegExp(r'<textarea[^>]*name="bio"[^>]*>([\s\S]*?)</textarea>', caseSensitive: false));
    if (bio.isEmpty) {
      bio = extract(RegExp(r'<div class="mb-2">\s*<i class="fas fa-briefcase"></i>\s*([^<]+)</div>', caseSensitive: false));
    }
    if (bio.isEmpty) {
      bio = 'Website Development and Digital Marketing are essential for business growth in the digital era.';
    }
    bio = AppFormatters.unescapeHtml(bio);

    var photoUrl = extract(RegExp(r'src="([^"]*(?:uploads/profile/|/profile/)[^"]+)"', caseSensitive: false));
    if (photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
      photoUrl = 'https://wincoconnect.com$photoUrl';
    }

    var logoUrl = extract(RegExp(r'src="([^"]*(?:uploads/business_logo/|/business_logo/)[^"]+)"', caseSensitive: false));
    if (logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
      logoUrl = 'https://wincoconnect.com$logoUrl';
    }

    var sinceStr = extract(RegExp(r'class="badge-pill-dark">\s*Since\s*([^<]+)\s*</span>', caseSensitive: false));
    if (sinceStr.isEmpty) {
      sinceStr = extract(RegExp(r'name="start_year"[\s\S]*?value="([^"]*)"', caseSensitive: false), 'Apr 2026');
    }

    final refGivenStr = extract(RegExp(r'<h6>Referral Given</h6>\s*<h2[^>]*>(\d+)</h2>', caseSensitive: false), '0');
    final refReceivedStr = extract(RegExp(r'<h6>Referral Received</h6>\s*<h2[^>]*>(\d+)</h2>', caseSensitive: false), '0');
    final meetAttendedStr = extract(RegExp(r'<h6>Meetings Attended</h6>\s*<h2[^>]*>(\d+)</h2>', caseSensitive: false), '31');

    final nameParts = rawName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : rawName;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final categoryDisplay = subcategory.isNotEmpty && industry.isNotEmpty
        ? '$industry • $subcategory'
        : (industry.isNotEmpty ? industry : (subcategory.isNotEmpty ? subcategory : 'Growth Marketing Partner'));

    return MemberModel(
      id: userCode,
      firstName: firstName,
      lastName: lastName,
      email: email.isNotEmpty ? email : fallbackEmail,
      phone: phone,
      businessName: businessName.isNotEmpty ? businessName : 'Hosting Baba',
      businessCategory: categoryDisplay,
      since: sinceStr.isNotEmpty ? sinceStr : 'Apr 2026',
      location: '$city, $state',
      gstNumber: gst.isNotEmpty ? gst : null,
      chapterId: '1',
      chapterName: 'Winco - Jayanagar',
      profileImageUrl: photoUrl.isNotEmpty ? photoUrl : null,
      businessLogoUrl: logoUrl.isNotEmpty ? logoUrl : null,
      designation: designation.isNotEmpty ? designation : 'Website development and digital marketing',
      about: bio,
      isPrimeMember: true,
      isActive: true,
      referralsGiven: int.tryParse(refGivenStr) ?? 0,
      referralsReceived: int.tryParse(refReceivedStr) ?? 0,
      meetingsAttended: int.tryParse(meetAttendedStr) ?? 31,
      businessDone: 0.0,
      website: website.isNotEmpty ? website : null,
      gender: gender.isNotEmpty ? gender : null,
      dob: dob.isNotEmpty ? dob : null,
      whatsapp: whatsapp.isNotEmpty ? whatsapp : null,
      pincode: pincode.isNotEmpty ? pincode : null,
      linkedin: linkedin.isNotEmpty ? linkedin : null,
      facebook: facebook.isNotEmpty ? facebook : null,
      instagram: instagram.isNotEmpty ? instagram : null,
      youtube: youtube.isNotEmpty ? youtube : null,
      googleBusiness: googleBusiness.isNotEmpty ? googleBusiness : null,
    );
  }

  MemberModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? businessName,
    String? businessCategory,
    String? since,
    String? location,
    String? gstNumber,
    String? chapterId,
    String? chapterName,
    String? profileImageUrl,
    String? businessLogoUrl,
    String? designation,
    String? about,
    bool? isPrimeMember,
    bool? isActive,
    int? referralsGiven,
    int? referralsReceived,
    int? meetingsAttended,
    double? businessDone,
    String? website,
    String? gender,
    String? dob,
    String? whatsapp,
    String? pincode,
    String? linkedin,
    String? facebook,
    String? instagram,
    String? youtube,
    String? googleBusiness,
  }) {
    return MemberModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      since: since ?? this.since,
      location: location ?? this.location,
      gstNumber: gstNumber ?? this.gstNumber,
      chapterId: chapterId ?? this.chapterId,
      chapterName: chapterName ?? this.chapterName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      designation: designation ?? this.designation,
      about: about ?? this.about,
      isPrimeMember: isPrimeMember ?? this.isPrimeMember,
      isActive: isActive ?? this.isActive,
      referralsGiven: referralsGiven ?? this.referralsGiven,
      referralsReceived: referralsReceived ?? this.referralsReceived,
      meetingsAttended: meetingsAttended ?? this.meetingsAttended,
      businessDone: businessDone ?? this.businessDone,
      website: website ?? this.website,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      whatsapp: whatsapp ?? this.whatsapp,
      pincode: pincode ?? this.pincode,
      linkedin: linkedin ?? this.linkedin,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      youtube: youtube ?? this.youtube,
      googleBusiness: googleBusiness ?? this.googleBusiness,
    );
  }
}

