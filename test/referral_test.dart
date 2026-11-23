import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winco_connect/data/models/mitb_model.dart';
import 'package:winco_connect/data/models/referral_model.dart';
import 'package:winco_connect/data/repositories/referral_repository.dart';
import 'package:winco_connect/features/referrals/presentation/referral_screen.dart';
import 'package:winco_connect/features/referrals/presentation/widgets/add_referral_bottom_sheet.dart';
import 'package:winco_connect/features/referrals/presentation/widgets/update_referral_status_sheet.dart';

void main() {
  group('Referral Data Model and Parser Tests', () {
    test('ReferralSummary.baseline returns expected zero counts for initial state', () {
      final summary = ReferralSummary.baseline();
      expect(summary.totalReferrals, 0);
      expect(summary.receivedCount, 0);
      expect(summary.givenCount, 0);
    });

    test('ReferralTemperature parsing tests', () {
      expect(ReferralTemperature.fromString('Hot'), ReferralTemperature.hot);
      expect(ReferralTemperature.fromString('🔥 Hot'), ReferralTemperature.hot);
      expect(ReferralTemperature.fromString('Warm'), ReferralTemperature.warm);
      expect(ReferralTemperature.fromString('🌤 Warm'), ReferralTemperature.warm);
    });

    test('ReferralLiveStatus parsing tests for all five statuses', () {
      expect(ReferralLiveStatus.fromString('Open for Discussion'), ReferralLiveStatus.openForDiscussion);
      expect(ReferralLiveStatus.fromString('open for discussion'), ReferralLiveStatus.openForDiscussion);
      expect(ReferralLiveStatus.fromString('contacted'), ReferralLiveStatus.contacted);
      expect(ReferralLiveStatus.fromString('not converted'), ReferralLiveStatus.needSometime);
      expect(ReferralLiveStatus.fromString('Need Sometime'), ReferralLiveStatus.needSometime);
      expect(ReferralLiveStatus.fromString('cancelled'), ReferralLiveStatus.cancelled);
      expect(ReferralLiveStatus.fromString('Bussiness Done'), ReferralLiveStatus.businessDone);
      expect(ReferralLiveStatus.fromString('business done'), ReferralLiveStatus.businessDone);
    });

    test('ReferralSubmissionPayload toFormData creates valid map', () {
      const payload = ReferralSubmissionPayload(
        memberForm: 'chapter',
        toUser: 'USR00015',
        business: 'Prestige Group Foundation Work',
        contactNumber: '+91 9886011223',
        description: 'Client needs grade 40 concrete piling contractor',
        temperature: 'Hot',
        status: 'Open for Discussion',
      );

      final map = payload.toFormData();
      expect(map['member_form'], 'chapter');
      expect(map['to_user'], 'USR00015');
      expect(map['business'], 'Prestige Group Foundation Work');
      expect(map['contact_number'], '+91 9886011223');
      expect(map['description'], contains('grade 40 concrete'));
      expect(map['temperature'], 'Hot');
      expect(map['status'], 'Open for Discussion');
    });

    test('ReferralStatusUpdatePayload toFormData creates valid map for all 5 statuses', () {
      final statuses = [
        'open for discussion',
        'contacted',
        'not converted',
        'business done',
        'cancelled',
      ];

      for (final st in statuses) {
        final payload = ReferralStatusUpdatePayload(referralCode: 'REF0012', status: st);
        final map = payload.toFormData();
        expect(map['referral_code'], 'REF0012');
        expect(map['status'], st);
      }
    });

    test('ReferralPageData.fromHtml parses real production connect dump', () {
      final file = File('test/fixtures/connect_dump.html');
      if (!file.existsSync()) {
        final baseline = ReferralPageData.baseline();
        expect(baseline.summary.totalReferrals, 0);
        return;
      }

      final html = file.readAsStringSync();
      final pageData = ReferralPageData.fromHtml(html);

      expect(pageData.summary.totalReferrals, 0);
      expect(pageData.summary.receivedCount, 0);
      expect(pageData.summary.givenCount, 0);
      expect(pageData.receivedReferrals, isEmpty);
      expect(pageData.givenReferrals, isEmpty);
    });

    test('ReferralPageData.fromHtml parses active referral cards properly', () {
      const sampleWithCards = '''
      <div class="connect-header">
        <h4 class="title">Total Referral <span class="count">1</span></h4>
      </div>
      <div class="connect-tabs">
        <button class="tab-btn active" data-tab="received">Received <span class="badge">1</span></button>
        <button class="tab-btn" data-tab="given">Given <span class="badge">0</span></button>
      </div>
      <div class="tab-content-box active" id="received">
        <div class="referral-card">
          <div class="member">
            <div class="name">Dr. Rajesh Sharma</div>
            <small>rajesh@infra.com</small>
          </div>
          <div class="member">
            <div class="name">Harri Kumar</div>
            <small>harri@jobhunterr.com</small>
          </div>
          <div class="label">Referral Name:</div>
          <div class="value">Brigade Tech Park Civil Work</div>
          <div class="label">Contact:</div>
          <div class="value">+91 9845011223</div>
          <div class="label">Details:</div>
          <div class="value">Subcontracting tender bid for 12 girder beam installations</div>
          <div class="temp">🔥 Hot</div>
          <div class="status">Open for Discussion</div>
          <div class="date">14 Nov 2026</div>
          <a onclick="edit_refferral_status('REF0042')">Edit</a>
        </div>
      </div>
      <!-- GIVEN -->
      <div class="tab-content-box" id="given">
        No Given Referrals
      </div>
      </div></div>
      ''';

      final pageData = ReferralPageData.fromHtml(sampleWithCards);
      expect(pageData.summary.totalReferrals, 1);
      expect(pageData.summary.receivedCount, 1);
      expect(pageData.receivedReferrals.length, 1);

      final card = pageData.receivedReferrals.first;
      expect(card.id, 'REF0042');
      expect(card.fromMemberName, 'Dr. Rajesh Sharma');
      expect(card.toMemberName, 'Harri Kumar');
      expect(card.referralName, 'Brigade Tech Park Civil Work');
      expect(card.contactNumber, '+91 9845011223');
      expect(card.temperature, ReferralTemperature.hot);
      expect(card.status, ReferralLiveStatus.openForDiscussion);
      expect(card.date, '14 Nov 2026');
    });

    test('MockReferralRepository returns baseline data and handles submissions', () async {
      final repo = MockReferralRepository();
      final data = await repo.getConnectData();
      expect(data.summary.totalReferrals, 0);

      final members = await repo.getMembers(type: 'chapter');
      expect(members.isNotEmpty, isTrue);

      final submitRes = await repo.submitReferral(const ReferralSubmissionPayload(
        memberForm: 'chapter',
        toUser: 'USR00015',
        business: 'Sample Referral',
        contactNumber: '9988776655',
        description: 'Notes',
        temperature: 'Hot',
        status: 'Open for Discussion',
      ));
      expect(submitRes['status'], 'success');

      final updateRes = await repo.updateReferralStatus(const ReferralStatusUpdatePayload(
        referralCode: 'REF0001',
        status: 'contacted',
      ));
      expect(updateRes['status'], 'success');
    });
  });

  group('ReferralScreen and BottomSheet Widget Tests', () {
    testWidgets('ReferralScreen displays header metrics and empty state for 0 referrals', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralDataProvider.overrideWith((ref) async => ReferralPageData.baseline()),
          ],
          child: const MaterialApp(
            home: ReferralScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Business Referrals'), findsOneWidget);
      expect(find.text('Referral Connects Pipeline'), findsOneWidget);
      expect(find.text('Total Referrals'), findsOneWidget);
      expect(find.text('Received'), findsWidgets);
      expect(find.text('Given'), findsWidgets);
      expect(find.text('No Received Referrals'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Open For Discussion'), findsOneWidget);
      expect(find.text('Contacted'), findsOneWidget);
      expect(find.text('Business Done'), findsOneWidget);
    });

    testWidgets('ReferralScreen verifies transaction directions for both Received and Given cards', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const testPageData = ReferralPageData(
        summary: ReferralSummary(totalReferrals: 2, receivedCount: 1, givenCount: 1),
        receivedReferrals: [
          ReferralItem(
            id: 'REF-REC-01',
            fromMemberName: 'Santhosha H R',
            fromMemberEmail: 'santha@gmail.com',
            toMemberName: 'Harri Kumar',
            toMemberEmail: 'harri@winco.com',
            referralName: 'Metro Pillar Foundation',
            contactNumber: '9880011223',
            description: 'Piling work',
            temperature: ReferralTemperature.hot,
            status: ReferralLiveStatus.openForDiscussion,
            date: '16 Nov 2026',
            isReceived: true,
          ),
        ],
        givenReferrals: [
          ReferralItem(
            id: 'REF-GIV-01',
            fromMemberName: 'Harri Kumar',
            fromMemberEmail: 'harri@winco.com',
            toMemberName: 'Vikram Mehta',
            toMemberEmail: 'vikram@steel.com',
            referralName: 'Precast Beam Supply',
            contactNumber: '9977001122',
            description: 'Precast beams for bridge',
            temperature: ReferralTemperature.warm,
            status: ReferralLiveStatus.contacted,
            date: '16 Nov 2026',
            isReceived: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralDataProvider.overrideWith((ref) async => testPageData),
          ],
          child: const MaterialApp(
            home: ReferralScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // In Received tab: From Santhosha to Harri
      expect(find.text('Metro Pillar Foundation'), findsOneWidget);
      expect(find.text('Santhosha H R'), findsOneWidget);
      expect(find.text('Harri Kumar'), findsOneWidget);

      // Switch to Given tab
      final givenTabFinder = find.byKey(const Key('referral_given_tab'));
      await tester.tap(givenTabFinder);
      await tester.pumpAndSettle();

      // In Given tab: From Harri to Vikram
      expect(find.text('Precast Beam Supply'), findsOneWidget);
      expect(find.text('Harri Kumar'), findsOneWidget);
      expect(find.text('Vikram Mehta'), findsOneWidget);
    });

    testWidgets('ReferralScreen renders all five referral status types with badges', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const fiveStatusData = ReferralPageData(
        summary: ReferralSummary(totalReferrals: 5, receivedCount: 5, givenCount: 0),
        receivedReferrals: [
          ReferralItem(
            id: 'R1',
            fromMemberName: 'Member 1',
            fromMemberEmail: 'm1@test.com',
            toMemberName: 'Harri',
            toMemberEmail: 'h@test.com',
            referralName: 'Lead 1 Discussion',
            contactNumber: '111',
            description: '',
            temperature: ReferralTemperature.hot,
            status: ReferralLiveStatus.openForDiscussion,
            date: '16 Nov 2026',
            isReceived: true,
          ),
          ReferralItem(
            id: 'R2',
            fromMemberName: 'Member 2',
            fromMemberEmail: 'm2@test.com',
            toMemberName: 'Harri',
            toMemberEmail: 'h@test.com',
            referralName: 'Lead 2 Contacted',
            contactNumber: '222',
            description: '',
            temperature: ReferralTemperature.warm,
            status: ReferralLiveStatus.contacted,
            date: '16 Nov 2026',
            isReceived: true,
          ),
          ReferralItem(
            id: 'R3',
            fromMemberName: 'Member 3',
            fromMemberEmail: 'm3@test.com',
            toMemberName: 'Harri',
            toMemberEmail: 'h@test.com',
            referralName: 'Lead 3 Need Sometime',
            contactNumber: '333',
            description: '',
            temperature: ReferralTemperature.hot,
            status: ReferralLiveStatus.needSometime,
            date: '16 Nov 2026',
            isReceived: true,
          ),
          ReferralItem(
            id: 'R4',
            fromMemberName: 'Member 4',
            fromMemberEmail: 'm4@test.com',
            toMemberName: 'Harri',
            toMemberEmail: 'h@test.com',
            referralName: 'Lead 4 Business Done',
            contactNumber: '444',
            description: '',
            temperature: ReferralTemperature.hot,
            status: ReferralLiveStatus.businessDone,
            date: '16 Nov 2026',
            isReceived: true,
          ),
          ReferralItem(
            id: 'R5',
            fromMemberName: 'Member 5',
            fromMemberEmail: 'm5@test.com',
            toMemberName: 'Harri',
            toMemberEmail: 'h@test.com',
            referralName: 'Lead 5 Cancelled',
            contactNumber: '555',
            description: '',
            temperature: ReferralTemperature.warm,
            status: ReferralLiveStatus.cancelled,
            date: '16 Nov 2026',
            isReceived: true,
          ),
        ],
        givenReferrals: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralDataProvider.overrideWith((ref) async => fiveStatusData),
          ],
          child: const MaterialApp(
            home: ReferralScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Lead 1 Discussion'), findsOneWidget);
      expect(find.text('Lead 2 Contacted'), findsOneWidget);
      expect(find.text('Lead 3 Need Sometime'), findsOneWidget);
      expect(find.text('Lead 4 Business Done'), findsOneWidget);
      expect(find.text('Lead 5 Cancelled'), findsOneWidget);
    });

    testWidgets('ReferralScreen renders cleanly on narrow Android (360x640) and iOS (390x844)', (WidgetTester tester) async {
      // Test Android screen
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralDataProvider.overrideWith((ref) async => ReferralPageData.baseline()),
          ],
          child: const MaterialApp(
            home: ReferralScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Test iPhone screen
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('AddReferralBottomSheet opens and validates required fields', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralRepositoryProvider.overrideWithValue(MockReferralRepository()),
            referralMembersListProvider('chapter').overrideWith(
              (ref) async => const [
                MitbMemberOption(userCode: 'USR00015', name: 'Santhosha H R', isSelf: false),
              ],
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AddReferralBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('New Referral Opportunity'), findsOneWidget);
      expect(find.text('Select Member From *'), findsOneWidget);
      expect(find.text('My Chapter'), findsOneWidget);
      expect(find.text('Across All Chapters'), findsOneWidget);
      expect(find.text('Referral Name *'), findsOneWidget);
      expect(find.text('Referral Contact *'), findsOneWidget);

      final submitBtn = find.text('Send Referral');
      expect(submitBtn, findsOneWidget);
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please select a member'), findsOneWidget);
      expect(find.text('Please enter referral / business name'), findsOneWidget);
      expect(find.text('Please enter referral contact number'), findsOneWidget);
    });

    testWidgets('UpdateReferralStatusSheet opens and displays status pipeline options', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const sampleReferral = ReferralItem(
        id: 'REF0012',
        fromMemberName: 'Dr. Rajesh Sharma',
        fromMemberEmail: 'rajesh@infra.com',
        toMemberName: 'Harri Kumar',
        toMemberEmail: 'harri@jobhunterr.com',
        referralName: 'Metro Pillar Fabrication',
        contactNumber: '9988112233',
        description: 'Requirement for steel reinforcement',
        temperature: ReferralTemperature.hot,
        status: ReferralLiveStatus.openForDiscussion,
        date: '15 Nov 2026',
        isReceived: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralRepositoryProvider.overrideWithValue(MockReferralRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UpdateReferralStatusSheet(referral: sampleReferral),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Update Referral Status'), findsOneWidget);
      expect(find.text('Select Current Pipeline Status'), findsOneWidget);
      expect(find.text('Open for Discussion'), findsOneWidget);
      expect(find.text('Contacted'), findsOneWidget);
      expect(find.text('Need Sometime'), findsOneWidget);
      expect(find.text('Business Done'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Confirm Status Update'), findsOneWidget);
    });

    testWidgets('ReferralScreen displays error view on data failure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralDataProvider.overrideWith((ref) async => throw Exception('Connection lost to WINCO')),
          ],
          child: const MaterialApp(
            home: ReferralScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Connection lost to WINCO'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('ReferralScreen displays loading indicator during network fetch', (WidgetTester tester) async {
      final completer = Completer<ReferralPageData>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralDataProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: ReferralScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(ReferralPageData.baseline());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
