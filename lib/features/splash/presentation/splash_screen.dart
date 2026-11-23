import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/storage/secure_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _networkError = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSessionValidation();
    });
  }

  Future<void> _startSessionValidation() async {
    setState(() {
      _networkError = false;
      _isChecking = true;
    });

    // In mock mode (e.g. widget testing or offline preview), proceed to home immediately
    if (AppConfig.current.isMock) {
      if (mounted) context.go('/');
      return;
    }

    final storage = ref.read(secureStorageServiceProvider);
    final isLoggedIn = await storage.isLoggedIn();

    if (!isLoggedIn) {
      if (mounted) context.go('/');
      return;
    }

    // Production environment: Wait briefly for branding display, then validate session
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0 Safari/537.36',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );

      final cookies = await storage.getSessionCookies();
      final response = await dio.get(
        'https://wincoconnect.com/member/dashboard',
        options: Options(
          headers: {
            if (cookies != null && cookies.isNotEmpty) 'Cookie': cookies,
          },
          responseType: ResponseType.plain,
        ),
      );

      final location = response.headers.value('location') ?? '';
      final body = response.data?.toString() ?? '';

      // Check if session is alive (contains dashboard markers and not redirected to login)
      final isSessionValid = (response.statusCode == 200 &&
              (body.contains('Business Performance') ||
                  body.contains('Hello ') ||
                  body.contains('Business Given'))) &&
          !location.contains('/login') &&
          !location.contains('loginCheck');

      if (isSessionValid) {
        // Save any refreshed session cookies from server
        final setCookies = response.headers['set-cookie'];
        if (setCookies != null && setCookies.isNotEmpty) {
          final cookieHeader =
              setCookies.map((c) => c.split(';').first).join('; ');
          await storage.saveSessionCookies(cookieHeader);
          for (final c in setCookies) {
            if (c.contains('ci_session=')) {
              final m = RegExp(r'ci_session=([^;]+)').firstMatch(c);
              if (m != null) await storage.saveCiSession(m.group(1)!);
            }
          }
        }
        if (mounted) context.go('/dashboard');
      } else {
        // Session expired on server: clear storage and route to login
        await storage.clearSession();
        if (mounted) context.go('/login');
      }
    } catch (_) {
      // Network timeout or offline: preserve session and allow retry / offline access
      if (mounted) {
        setState(() {
          _networkError = true;
          _isChecking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBurgundy,
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryBurgundy.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.wineGradientEnd.withOpacity(0.6),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // WINCO Brand Logo inside crisp white circular card
                          Container(
                            width: 130,
                            height: 130,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AssetConstants.logo,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.business,
                                    size: 64,
                                    color: AppColors.primaryBurgundy,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App Name
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tagline
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AppConstants.communityName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                          if (_networkError) ...[
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Offline Mode Available',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cannot verify server connection right now. Your session is securely preserved.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _startSessionValidation,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Colors.white),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              context.go('/dashboard'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.accentOrange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Continue'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isChecking && !_networkError && !AppConfig.current.isMock)
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
