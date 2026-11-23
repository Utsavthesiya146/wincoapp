import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage_service.dart';

class WebViewFallbackScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewFallbackScreen({
    super.key,
    required this.url,
    this.title = 'WINCO Connect',
  });

  @override
  State<WebViewFallbackScreen> createState() => _WebViewFallbackScreenState();
}

class _WebViewFallbackScreenState extends State<WebViewFallbackScreen> {
  late final WebViewController _controller;
  final _storage = SecureStorageService();
  int _loadingProgress = 0;
  bool _hasError = false;

  final Set<String> _allowedHosts = {
    'wincoconnect.com',
    'www.wincoconnect.com',
  };

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _hasError = false;
                _loadingProgress = 0;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) setState(() => _loadingProgress = 100);

            // Synchronize authenticated session if user logged in via WebView
            if (url.contains('/member/dashboard') || url.contains('/member')) {
              try {
                final cookies = await _controller.runJavaScriptReturningResult('document.cookie');
                final cookieStr = cookies.toString().replaceAll('"', '');
                if (cookieStr.contains('ci_session=')) {
                  final match = RegExp(r'ci_session=([^;]+)').firstMatch(cookieStr);
                  if (match != null) {
                    await _storage.saveCiSession(match.group(1)!);
                    await _storage.saveSessionCookies(cookieStr);
                  }
                }
              } catch (_) {}
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) setState(() => _hasError = true);
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && uri.scheme == 'https' && _allowedHosts.contains(uri.host)) {
              return NavigationDecision.navigate;
            }
            // Block unapproved domains or insecure http
            return NavigationDecision.prevent;
          },
        ),
      );

    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    // Inject stored native session cookie into WebView before load
    final ciSession = await _storage.getCiSession();
    if (ciSession != null && ciSession.isNotEmpty) {
      try {
        final cookieManager = WebViewCookieManager();
        await cookieManager.setCookie(
          WebViewCookie(
            name: 'ci_session',
            value: ciSession,
            domain: 'wincoconnect.com',
            path: '/',
          ),
        );
      } catch (_) {}
    }

    final safeUri = Uri.tryParse(widget.url);
    if (safeUri != null && safeUri.scheme == 'https') {
      _controller.loadRequest(safeUri);
    } else {
      _controller.loadRequest(Uri.parse(AppConstants.officialWebsite));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load webpage',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please ensure you have an active internet connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => _controller.reload(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          if (_loadingProgress < 100 && !_hasError)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBurgundy),
            ),
        ],
      ),
    );
  }
}

