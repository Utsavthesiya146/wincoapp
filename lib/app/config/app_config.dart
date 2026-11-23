enum AppEnvironment {
  mock,
  staging,
  production,
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String websiteUrl;
  final String supportEmail;
  final String supportPhone;
  final String appName;
  final String appTagline;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.websiteUrl,
    required this.supportEmail,
    required this.supportPhone,
    required this.appName,
    required this.appTagline,
    this.connectTimeoutMs = 15000,
    this.receiveTimeoutMs = 15000,
  });

  bool get isMock => environment == AppEnvironment.mock;
  bool get isProduction => environment == AppEnvironment.production;

  static AppConfig? _current;

  static AppConfig get current {
    _current ??= production;
    return _current!;
  }

  static void setConfig(AppConfig config) {
    _current = config;
  }

  /// Default Production Configuration
  /// Ready to connect to https://wincoconnect.com
  static const AppConfig production = AppConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://wincoconnect.com/api/v1',
    websiteUrl: 'https://wincoconnect.com',
    supportEmail: 'info@wincoconnect.com',
    supportPhone: '+91 9886115993',
    appName: 'WINCO CONNECT',
    appTagline: 'Bridging the Gap',
  );

  /// Mock Configuration for UI Testing & App Store review without network dependency
  static const AppConfig mock = AppConfig(
    environment: AppEnvironment.mock,
    apiBaseUrl: 'https://mock.wincoconnect.local/api/v1',
    websiteUrl: 'https://wincoconnect.com',
    supportEmail: 'info@wincoconnect.com',
    supportPhone: '+91 9886115993',
    appName: 'WINCO CONNECT',
    appTagline: 'Bridging the Gap',
  );
}

