import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winco_connect/app/app.dart';
import 'package:winco_connect/app/config/app_config.dart';
import 'package:winco_connect/core/constants/app_constants.dart';
import 'package:winco_connect/core/utils/validators.dart';

void main() {
  setUpAll(() {
    AppConfig.setConfig(AppConfig.mock);
  });
  group('WINCO Connect Form Validation Unit Tests', () {
    test('Email validator tests', () {
      expect(AppValidators.validateEmail(''), isNotNull);
      expect(AppValidators.validateEmail('not-an-email'), isNotNull);
      expect(AppValidators.validateEmail('info@wincoconnect.com'), isNull);
    });

    test('Phone validator tests (10 digits)', () {
      expect(AppValidators.validatePhone(''), isNotNull);
      expect(AppValidators.validatePhone('12345'), isNotNull);
      expect(AppValidators.validatePhone('9886115993'), isNull);
      expect(AppValidators.validatePhone('+919886115993'), isNull);
    });

    test('Required field validator tests', () {
      expect(AppValidators.validateRequired(null, 'First Name'), isNotNull);
      expect(AppValidators.validateRequired('', 'First Name'), isNotNull);
      expect(AppValidators.validateRequired('John', 'First Name'), isNull);
    });

    test('GST validator tests (optional)', () {
      expect(AppValidators.validateGstOptional(null), isNull);
      expect(AppValidators.validateGstOptional(''), isNull);
      expect(AppValidators.validateGstOptional('29ABCDE1234F1Z5'), isNull);
      expect(AppValidators.validateGstOptional('INVALIDGST'), isNotNull);
    });
  });

  group('Three Screens UI & Navigation Integration Tests', () {
    testWidgets('Screen 1: Home displays brand, JOIN NOW and MEMBER LOGIN buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Screen 1: Verify Home Brand & Tagline
      expect(find.text('WORLD INFRA NETWORKING COMMUNITY'), findsOneWidget);
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.appTagline), findsOneWidget);

      // Verify two prominent buttons
      expect(find.text('JOIN NOW'), findsOneWidget);
      expect(find.text('MEMBER LOGIN'), findsOneWidget);
    });

    testWidgets('Navigation: JOIN NOW opens Join Community Registration Screen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Click JOIN NOW
      await tester.tap(find.text('JOIN NOW'));
      await tester.pumpAndSettle();

      // Screen 2: Verify Registration Screen elements
      expect(find.text('Join the Community'), findsWidgets);
      expect(find.text('Connect. Grow. Succeed.'), findsOneWidget);
      expect(find.text('Get in Touch With Us'), findsOneWidget);
      expect(find.text('SUBMIT'), findsOneWidget);

      // Verify Back Navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Should be back on Home Screen
      expect(find.text('MEMBER LOGIN'), findsOneWidget);
    });

    testWidgets('Navigation: MEMBER LOGIN opens Member Login Screen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Click MEMBER LOGIN
      await tester.tap(find.text('MEMBER LOGIN'));
      await tester.pumpAndSettle();

      // Screen 3: Verify Member Login elements
      expect(find.text('Member Login'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);

      // Verify Back Navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Should be back on Home Screen
      expect(find.text('JOIN NOW'), findsOneWidget);
    });

    testWidgets('Navigation: Explore About opens AboutScreen with Mission & Vision',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap About in Quick Nav
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Verify Screen 4: AboutScreen content
      expect(find.text('About WINCO Connect'), findsOneWidget);
      expect(find.text('Our Mission'), findsOneWidget);
      expect(find.text('Our Vision'), findsOneWidget);
      expect(find.text('Why Choose Us?'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('JOIN NOW'), findsOneWidget);
    });

    testWidgets('Navigation: Explore Contact opens ContactScreen with form and verified info',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Contact in Quick Nav
      await tester.tap(find.text('Contact'));
      await tester.pumpAndSettle();

      // Verify Screen 5: ContactScreen content
      expect(find.text('Contact Support & Inquiries'), findsOneWidget);
      expect(find.text('Get in Touch with Us'), findsOneWidget);
      expect(find.text('Send Us a Direct Message'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('JOIN NOW'), findsOneWidget);
    });

    testWidgets('Navigation: Explore Blogs opens BlogsScreen with knowledge hub',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Blogs in Quick Nav
      await tester.tap(find.text('Blogs'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Screen 6: BlogsScreen content
      expect(find.text('Blogs & Knowledge Hub'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('JOIN NOW'), findsOneWidget);
    });

    testWidgets('Navigation: Explore Chapters opens ChaptersScreen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Chapters in Quick Nav
      await tester.tap(find.text('Chapters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Screen 7: ChaptersScreen content
      expect(find.text('Chapters & Conclaves'), findsOneWidget);
      expect(find.text('Regional Chapters'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('JOIN NOW'), findsOneWidget);
    });

    testWidgets('Navigation: Explore Prime opens PrimeClubScreen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: WincoConnectApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Prime in Quick Nav
      await tester.tap(find.text('Prime'));
      await tester.pumpAndSettle();

      // Verify Screen 8: PrimeClubScreen content
      expect(find.text('WINCO PRIME CLUB'), findsOneWidget);
      expect(find.text('Exclusive Tier for Infrastructure Leaders'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('JOIN NOW'), findsOneWidget);
    });
  });
}
