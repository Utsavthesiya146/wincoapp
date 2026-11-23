import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/member_model.dart';

abstract class AuthRepository {
  Future<MemberModel> login({required String email, required String password});
  Future<void> logout();
  Future<MemberModel?> getCurrentUser();
  Future<bool> isAuthenticated();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockAuthRepository(storage);
  } else {
    return LiveAuthRepository(apiClient: apiClient, storage: storage);
  }
});

/// Live API Implementation
/// Connects to WINCO backend authentication endpoint (POST /loginCheck)
class LiveAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  LiveAuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<MemberModel> login({required String email, required String password}) async {
    // 1. Direct authentication with CodeIgniter backend: https://wincoconnect.com/loginCheck
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0 Safari/537.36',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    final response = await dio.post(
      'https://wincoconnect.com/loginCheck',
      data: {
        'email': email.trim(),
        'password': password,
      },
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    final redirectLocation = response.headers.value('location') ?? '';
    final rawCookies = response.headers['set-cookie'] ?? [];

    String? ciSessionValue;
    for (final c in rawCookies) {
      if (c.contains('ci_session=')) {
        final m = RegExp(r'ci_session=([^;]+)').firstMatch(c);
        if (m != null) ciSessionValue = m.group(1);
        break;
      }
    }

    if (rawCookies.isNotEmpty) {
      final cookieHeader = rawCookies.map((c) => c.split(';').first).join('; ');
      await _storage.saveSessionCookies(cookieHeader);
    }
    if (ciSessionValue != null) {
      await _storage.saveCiSession(ciSessionValue);
      await _storage.saveAuthToken(ciSessionValue);
    }

    // Check for success redirect (redirect to /member/dashboard or 200 OK)
    final isSuccess = redirectLocation.contains('/member') ||
        redirectLocation.contains('/dashboard') ||
        (response.statusCode == 200 && !response.data.toString().contains('Invalid'));

    if (isSuccess) {
      MemberModel member = MockAuthRepository.mockMember.copyWith(email: email.trim());

      try {
        final profileResp = await _apiClient.get(
          'https://wincoconnect.com/member/profile',
          options: Options(
            responseType: ResponseType.plain,
            headers: {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'},
          ),
        );
        final pHtml = profileResp.data?.toString() ?? '';
        if (pHtml.isNotEmpty && !pHtml.contains('loginCheck')) {
          member = MemberModel.fromProfileHtml(pHtml, fallbackEmail: email.trim());
        }
      } catch (_) {}

      await _storage.saveUserSession(member.toJson());
      return member;
    } else {
      throw UnauthorizedException('Invalid credentials. Please verify your username and password.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _storage.clearSession();
    } catch (_) {}

    try {
      await _apiClient
          .get('https://wincoconnect.com/logout')
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // Allow local logout even if server fails
    }

    try {
      await WebViewCookieManager().clearCookies();
    } catch (_) {
      // Graceful fallback for test/desktop environments without native webview
    }
  }

  @override
  Future<MemberModel?> getCurrentUser() async {
    final cookies = await _storage.getSessionCookies();
    if (cookies != null && cookies.isNotEmpty) {
      // 1. Fetch fresh live profile from website to ensure all photos and data are always 100% in sync
      try {
        final profileResp = await _apiClient.get(
          'https://wincoconnect.com/member/profile',
          options: Options(
            responseType: ResponseType.plain,
            headers: {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'},
          ),
        );
        final pHtml = profileResp.data?.toString() ?? '';
        if (pHtml.isNotEmpty && !pHtml.contains('loginCheck')) {
          final session = await _storage.getUserSession();
          final fallbackEmail = session?['email']?.toString() ?? '';
          final member = MemberModel.fromProfileHtml(pHtml, fallbackEmail: fallbackEmail);
          await _storage.saveUserSession(member.toJson());
          return member;
        }
      } catch (_) {
        // Network offline: fall back to cached session below
      }
    }

    final session = await _storage.getUserSession();
    if (session != null) {
      return MemberModel.fromJson(session);
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _storage.isLoggedIn();
  }
}

/// Mock Implementation for UI Architecture, Offline Preview & Test Suites
class MockAuthRepository implements AuthRepository {
  final SecureStorageService _storage;

  MockAuthRepository(this._storage);

  static const MemberModel mockMember = MemberModel(
    id: 'USR00001',
    firstName: 'Harri',
    lastName: 'Kumar',
    email: 'harri@jobhunterr.com',
    phone: '9341873532',
    businessName: 'Hosting Baba',
    businessCategory: 'Growth Marketing Partner • Digital Marketing',
    since: 'Apr 2026',
    location: 'Bangalore, Karnataka',
    gstNumber: null,
    chapterId: '1',
    chapterName: 'Winco - Jayanagar',
    profileImageUrl: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
    businessLogoUrl: 'https://wincoconnect.com/uploads/business_logo/1780133245_79af4e0d13458afd7e91.jpeg',
    designation: 'Website development and digital marketing',
    about: 'Website Development and Digital Marketing are essential for business growth in the digital era. A professionally developed website showcases your brand, products, and services, while digital marketing techniques such as SEO, social media marketing, Google Ads, and content marketing help drive traffic, generate leads, and increase sales.',
    isPrimeMember: true,
    isActive: true,
    referralsGiven: 0,
    referralsReceived: 0,
    meetingsAttended: 31,
    businessDone: 0.0,
    website: 'https://webhostingbaba.com',
  );

  @override
  Future<MemberModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Allow mock demo credentials
    if (password.length < 4) {
      throw Exception('Invalid credentials. Password too short.');
    }

    final loggedUser = mockMember.copyWith(email: email);
    await _storage.saveAuthToken('mock_winco_jwt_token_sample');
    await _storage.saveUserSession(loggedUser.toJson());
    return loggedUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _storage.clearSession();
  }

  @override
  Future<MemberModel?> getCurrentUser() async {
    final session = await _storage.getUserSession();
    if (session != null) {
      return MemberModel.fromJson(session);
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _storage.isLoggedIn();
  }
}

