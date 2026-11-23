import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/network/api_client.dart';

abstract class ContactRepository {
  Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  });
}

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockContactRepository();
  } else {
    return LiveContactRepository(apiClient);
  }
});

class LiveContactRepository implements ContactRepository {
  final ApiClient _apiClient;

  LiveContactRepository(this._apiClient);

  @override
  Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    // Verified live website contact form endpoint: https://wincoconnect.com/contact_save
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phone': phone,
        'subject': subject,
        'message': message,
      });

      final response = await dio.post(
        'https://wincoconnect.com/contact_save',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Mobile; WincoConnectFlutterApp)',
          },
        ),
      );

      // 200 OK or 302/303 redirect indicates successful form processing by CodeIgniter
      return response.statusCode == 200 || response.statusCode == 302 || response.statusCode == 303;
    } catch (_) {
      // Fallback via primary apiClient if direct submission fails
      try {
        final response = await _apiClient.post(
          '/contact_save',
          data: {
            'name': name,
            'email': email,
            'phone': phone,
            'subject': subject,
            'message': message,
          },
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (_) {
        return false;
      }
    }
  }
}

class MockContactRepository implements ContactRepository {
  @override
  Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}

