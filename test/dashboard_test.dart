import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winco_connect/data/models/member_dashboard_model.dart';
import 'package:winco_connect/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  group('MemberDashboardModel Live HTML Parser Tests', () {
    const sampleDashboardHtml = '''
<!DOCTYPE html>
<html>
<body>
  <span>Hello Harri Kumar</span>
  <span>Chapter:</span><span>Winco - Jayanagar</span>
  <span>USR00001</span>
  <script>
    let target = 76;
    const labels = ["29 Jun","16 Nov"];
    const givenData = [0,0];
    const receivedData = [100000,0];
  </script>
  <marquee behavior="scroll">
    💰 Business Done: ₹7,77,43,407 &nbsp;|&nbsp;
    👥 Visitors: 3 &nbsp;|&nbsp;
    📤 Referral: 246 &nbsp;|&nbsp;
    📅 Meetings: 6 &nbsp;|&nbsp;
    🤝 121's Initiated: 32 &nbsp;|&nbsp;
    🏢 Chapters: 6 &nbsp;|&nbsp;
    👤 Members: 77
  </marquee>
  <small>Business Received</small><h5>₹1,00,000</h5>
  <small>Business Given</small><h5>₹0</h5>
  <small>Visitors</small><h5>0</h5>
  <small>Referral Given</small><h5>0</h5>
  <small>Referral Received</small><h5>0</h5>
  <small>Meetings</small><h5>1</h5>
  <small>121 Initiated By Me</small><h5>1</h5>
  <small>121 Initiated With Me</small><h5>1</h5>
  <span>Notifications 4</span>
  <span>Profile Strength 76%</span>
  <span>Total Members</span><h3>36</h3>
  <span>Total Business </span><h3>₹1,00,000</h3>
  <span>Total Referral</span><h3>311</h3>
  <span>121 Initiated</span><h3>30</h3>
  <span>Visitors</span><h3>1</h3>
  <span>Notifications</span><h3>273</h3>
  <div class="meeting-row">
    #1
    <b>24 Jul 2026</b>
    <small class="text-muted">09:45 AM</small>
    <div class="fw-semibold">Project Collaboration</div>
    <small class="text-muted">Winco - Jayanagar</small>
  </div>
</body>
</html>
''';

    test('MemberDashboardData.fromHtml parses all verified fields correctly', () {
      final data = MemberDashboardData.fromHtml(sampleDashboardHtml);

      // Authenticated User Identity
      expect(data.memberName, 'Harri Kumar');
      expect(data.memberCode, 'USR00001');
      expect(data.chapterName, 'Winco - Jayanagar');

      // Platform-wide Metrics
      expect(data.platform.businessDone, '₹7,77,43,407');
      expect(data.platform.visitors, 3);
      expect(data.platform.referrals, 246);
      expect(data.platform.meetings, 6);
      expect(data.platform.oneToOnes, 32);
      expect(data.platform.chapters, 6);
      expect(data.platform.members, 77);

      // Personal Member Metrics
      expect(data.personal.businessReceived, '₹1,00,000');
      expect(data.personal.businessGiven, '₹0');
      expect(data.personal.visitors, 0);
      expect(data.personal.referralsGiven, 0);
      expect(data.personal.referralsReceived, 0);
      expect(data.personal.meetings, 1);
      expect(data.personal.oneToOneByMe, 1);
      expect(data.personal.notifications, 4);
      expect(data.personal.profileStrength, '76%');

      // Chapter Metrics
      expect(data.chapter.totalMembers, 36);
      expect(data.chapter.totalBusiness, '₹1,00,000');
      expect(data.chapter.totalReferrals, 311);
      expect(data.chapter.oneToOnes, 30);

      // Business Report Dual-Series Chart
      expect(data.chart.labels, ['29 Jun', '16 Nov']);
      expect(data.chart.receivedData, [100000.0, 0.0]);
      expect(data.chart.givenData, [0.0, 0.0]);
      expect(data.chart.totalReceived, 100000.0);
      expect(data.chart.totalGiven, 0.0);

      // Recent Meeting
      expect(data.recentMeetings.length, 1);
      expect(data.recentMeetings.first.event, 'Project Collaboration');
      expect(data.recentMeetings.first.chapter, 'Winco - Jayanagar');
      expect(data.recentMeetings.first.date, '24 Jul 2026');
      expect(data.recentMeetings.first.time, '09:45 AM');
    });

    test('MemberDashboardData.baseline returns fallback with verified numbers', () {
      final baseline = MemberDashboardData.baseline();
      expect(baseline.memberName, 'Harri Kumar');
      expect(baseline.platform.businessDone, '₹7,77,43,407');
      expect(baseline.personal.businessReceived, '₹1,00,000');
    });
  });

  group('Native Member Dashboard UI Tests', () {
    testWidgets('DashboardScreen renders authenticated user welcome and verified metrics',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) async => MemberDashboardData.baseline(),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Welcome Card & Member Identity
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('Harri Kumar'), findsWidgets);
      expect(find.text('Chapter: Unassigned'), findsOneWidget);
      expect(find.text('USR00001'), findsOneWidget);

      // Quick Slips Hub
      expect(find.text('Quick Slips & Actions'), findsOneWidget);
      expect(find.text('Give MITB'), findsOneWidget);
      expect(find.text('Give Referral'), findsOneWidget);
      expect(find.text('Record 121'), findsOneWidget);
      expect(find.text('Invite Guest'), findsOneWidget);

      // Platform Performance Overview
      expect(find.text('WINCO Platform Performance'), findsOneWidget);
      expect(find.text('Total Business Done'), findsOneWidget);
      expect(find.text('₹7,77,43,407'), findsOneWidget);
      expect(find.text('Total Referrals'), findsWidgets);

      // Business Report Dual-Series Graph
      expect(find.text('Business Performance'), findsOneWidget);

      // Personal Business Performance
      expect(find.text('My Business Performance'), findsOneWidget);
      expect(find.text('Business Received'), findsOneWidget);
      expect(find.text('₹1,00,000'), findsWidgets);
      expect(find.text('Business Given'), findsOneWidget);
      expect(find.text('Meetings Attended'), findsOneWidget);
      expect(find.text('121 Initiated By Me'), findsOneWidget);
      expect(find.text('121 Initiated With Me'), findsOneWidget);

      // Recent Meeting Details
      expect(find.text('Recent Meeting Details'), findsOneWidget);
      expect(find.text('Project Collaboration'), findsOneWidget);

      // Chapter Performance
      expect(find.text('My Chapter Performance'), findsOneWidget);

      // More Modules
      expect(find.text('More Authenticated Modules'), findsOneWidget);
      expect(find.text('Top Performers'), findsOneWidget);
      expect(find.text('My Attendance'), findsOneWidget);
      expect(find.text('Performance Reports'), findsOneWidget);
    });

    testWidgets('DashboardScreen time filter chips switch active filter',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) async => MemberDashboardData.baseline(),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap 15D filter chip
      await tester.tap(find.text('15D').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap 1M filter chip
      await tester.tap(find.text('1M').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap 6M filter chip
      await tester.tap(find.text('6M').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap 12M filter chip
      await tester.tap(find.text('12M').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap All filter chip
      await tester.tap(find.text('All').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('WINCO Platform Performance'), findsOneWidget);
    });

    testWidgets('DashboardScreen renders cleanly on narrow Android screen (360x640) without overflow',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) async => MemberDashboardData.baseline(),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm no render overflow exception occurred
      final ex = tester.takeException();
      if (ex is FlutterError) {
        debugPrint(ex.toDiagnosticsNode().toStringDeep());
      }
      expect(ex, isNull);
      expect(find.text('Welcome back,'), findsOneWidget);
    });

    testWidgets('DashboardScreen renders cleanly on iPhone (390x844) without overflow',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) async => MemberDashboardData.baseline(),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Harri Kumar'), findsWidgets);
    });

    testWidgets('DashboardScreen displays loading state',
        (WidgetTester tester) async {
      final completer = Completer<MemberDashboardData>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) => completer.future,
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retrieving verified member metrics...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(MemberDashboardData.baseline());
      await tester.pump();
    });

    testWidgets('DashboardScreen displays error view on fetch failure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) async => throw Exception('Network connection timed out'),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to load member dashboard'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('DashboardScreen sign out dialog opens and dismisses on Cancel',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith(
              (ref) async => MemberDashboardData.baseline(),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Sign Out icon button
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify Dialog appears
      expect(find.text('Sign Out'), findsWidgets);
      expect(find.text('Are you sure you want to end your authenticated session?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Dialog should be dismissed
      expect(find.text('Are you sure you want to end your authenticated session?'), findsNothing);
    });
  });

  group('Dynamic Profile Strength & Dynamic Chapter Tests (No-Hardcode Validation)', () {
    test('Simulated profile strength 25% is extracted correctly', () {
      const html = '<html><body><span>Hello Harri</span><script>let target = 25;</script></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.personal.profileStrength, '25%');
    });

    test('Simulated profile strength 45% is extracted correctly', () {
      const html = '<html><body><span>Hello Harri</span><script>let target = 45;</script></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.personal.profileStrength, '45%');
    });

    test('Simulated profile strength 76% is extracted correctly', () {
      const html = '<html><body><span>Hello Harri</span><script>let target = 76;</script></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.personal.profileStrength, '76%');
    });

    test('Simulated profile strength 100% is extracted correctly', () {
      const html = '<html><body><span>Hello Harri</span><script>let target = 100;</script></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.personal.profileStrength, '100%');
    });

    test('Simulated unavailable profile strength falls back to Unavailable without hardcoded assumption', () {
      const html = '<html><body><span>Hello Harri</span><p>No target here</p></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.personal.profileStrength, 'Unavailable');
    });

    test('Dynamic chapter parsing extracts arbitrary chapter from HTML', () {
      const html = '<html><body><span>Chapter:</span><span>Winco - Whitefield</span></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.chapterName, 'Winco - Whitefield');
    });

    test('Dynamic chapter parsing defaults to Unassigned if not found and never hardcodes Jayanagar', () {
      const html = '<html><body><span>No chapter here</span></body></html>';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.chapterName, 'Unassigned');
    });

    test('Dynamic chapter priority uses passed parameter if provided', () {
      const html = '<html><body><span>Chapter:</span><span>Winco - Koramangala</span></body></html>';
      final data = MemberDashboardData.fromHtml(html, chapterName: 'Winco - Indiranagar');
      expect(data.chapterName, 'Winco - Indiranagar');
    });
  });

  group('Live Production 121 Initiated & Dashboard Metrics Discrepancy Regression Tests', () {
    test('Captured real production HTML dump extracts Chapter 121 Initiated = 30', () {
      final dumpFile = File('test/fixtures/dashboard_dump.html');
      if (dumpFile.existsSync()) {
        final realHtml = dumpFile.readAsStringSync();
        final data = MemberDashboardData.fromHtml(realHtml);
        expect(data.chapter.oneToOnes, 30);
        expect(data.chapter.totalMembers, 36);
        expect(data.chapter.totalBusiness, '₹1,00,000');
        expect(data.chapter.totalReferrals, 311);
        expect(data.chapter.visitors, 1);
        expect(data.chapter.notifications, 273);
        expect(data.personal.oneToOneByMe, 1);
        expect(data.personal.oneToOneWithMe, 1);
        expect(data.platform.oneToOnes, 32);
      }
    });

    test('Production HTML format with <b>121</b> Initiated extracts 30', () {
      const html = '''
        <div class="stat-card stat-info">
            <span><b style="font-weight: 700;color:#222222;">121</b> Initiated</span>
            <h3>30</h3>
        </div>
      ''';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.chapter.oneToOnes, 30);
    });

    test('Dynamic non-hardcoded 121 values are parsed accurately', () {
      const html45 = '''
        <div class="stat-card stat-info">
            <span><b style="font-weight: 700;color:#222222;">121</b> Initiated</span>
            <h3>45</h3>
        </div>
      ''';
      expect(MemberDashboardData.fromHtml(html45).chapter.oneToOnes, 45);

      const html12 = '''
        <div class="stat-card stat-info">
            <span><b style="font-weight: 700;color:#222222;">121</b> Initiated</span>
            <h3>12</h3>
        </div>
      ''';
      expect(MemberDashboardData.fromHtml(html12).chapter.oneToOnes, 12);
    });

    test('Genuine server 0 for 121 Initiated remains 0 (not null or error)', () {
      const html0 = '''
        <div class="stat-card stat-info">
            <span><b style="font-weight: 700;color:#222222;">121</b> Initiated</span>
            <h3>0</h3>
        </div>
      ''';
      expect(MemberDashboardData.fromHtml(html0).chapter.oneToOnes, 0);
    });

    test('Missing 121 Initiated HTML element yields null (not a false zero)', () {
      const htmlMissing = '<html><body><span>Total Members</span><h3>36</h3></body></html>';
      final data = MemberDashboardData.fromHtml(htmlMissing);
      expect(data.chapter.oneToOnes, isNull);
    });

    test('Personal 121 Initiated By Me and With Me parse <b> tags correctly', () {
      const html = '''
        <small style="line-height:1.2; display:block;"><b style="font-weight: 700;color:#222222;">121</b> Initiated By Me</small>
        <h5>5</h5>
        <small style="line-height:1.2; display:block;"><b style="font-weight: 700;color:#222222;">121</b> Initiated With Me</small>
        <h5>3</h5>
      ''';
      final data = MemberDashboardData.fromHtml(html);
      expect(data.personal.oneToOneByMe, 5);
      expect(data.personal.oneToOneWithMe, 3);
    });
  });
}
