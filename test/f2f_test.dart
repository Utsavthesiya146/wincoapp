import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winco_connect/data/models/f2f_model.dart';
import 'package:winco_connect/data/repositories/f2f_repository.dart';
import 'package:winco_connect/features/f2f/presentation/f2f_screen.dart';
import 'package:winco_connect/features/f2f/presentation/widgets/add_f2f_bottom_sheet.dart';
import 'package:winco_connect/features/f2f/presentation/widgets/update_f2f_status_sheet.dart';

void main() {
  group('F2F Data Model and Parser Tests', () {
    test('F2fStatus fromString parses all valid backend status strings', () {
      expect(F2fStatus.fromString('scheduled'), F2fStatus.scheduled);
      expect(F2fStatus.fromString('Scheduled'), F2fStatus.scheduled);
      expect(F2fStatus.fromString('completed'), F2fStatus.completed);
      expect(F2fStatus.fromString('Completed'), F2fStatus.completed);
      expect(F2fStatus.fromString('Re-scheduled'), F2fStatus.rescheduled);
      expect(F2fStatus.fromString('rescheduled'), F2fStatus.rescheduled);
      expect(F2fStatus.fromString('cancelled'), F2fStatus.cancelled);
      expect(F2fStatus.fromString('Cancelled'), F2fStatus.cancelled);
      expect(F2fStatus.fromString('unknown_state'), F2fStatus.scheduled);
    });

    test('F2fSubmissionPayload toFormData creates valid POST map', () {
      const payload = F2fSubmissionPayload(
        toUser: 'USR00015',
        date: '2026-11-17',
        location: 'CCD Jayanagar',
        summary: 'Met to discuss structural steel requirements',
      );

      final map = payload.toFormData();
      expect(map['to_user'], 'USR00015');
      expect(map['date'], '2026-11-17');
      expect(map['location'], 'CCD Jayanagar');
      expect(map['summary'], 'Met to discuss structural steel requirements');
    });

    test('F2fStatusUpdatePayload toFormData creates valid POST map', () {
      const payload = F2fStatusUpdatePayload(
        f2fCode: 'F2F0030',
        status: 'completed',
        summary: 'Successfully concluded discussion',
      );

      final map = payload.toFormData();
      expect(map['f2f_code'], 'F2F0030');
      expect(map['status'], 'completed');
      expect(map['summary'], 'Successfully concluded discussion');
    });

    test('F2fMemberOption displayText formats name with chapter', () {
      const opt = F2fMemberOption(
        userCode: 'USR00007',
        name: 'Santhosha H R',
        chapter: 'Winco - Jayanagar',
      );
      expect(opt.displayText, 'Santhosha H R (Winco - Jayanagar)');

      const optNoChapter = F2fMemberOption(
        userCode: 'USR00001',
        name: 'Harri Kumar',
        chapter: '',
      );
      expect(optNoChapter.displayText, 'Harri Kumar');
    });

    test('F2fPageData.fromHtml parses real production HTML dump', () {
      final dumpFile = File('test/fixtures/f2f_dump.html');
      if (dumpFile.existsSync()) {
        final html = dumpFile.readAsStringSync();
        final pageData = F2fPageData.fromHtml(html);

        expect(pageData.members.length, greaterThanOrEqualTo(50));
        expect(pageData.meetings.length, 1);

        final m = pageData.meetings.first;
        expect(m.id, '1');
        expect(m.f2fCode, 'F2F0030');
        expect(m.fromMemberName, 'Harri Kumar');
        expect(m.fromMemberEmail, 'harri@jobhunterr.com');
        expect(m.toMemberName, 'Manjunath D');
        expect(m.toMemberEmail, 'manjunath@vankarinteriors.com');
        expect(m.location, 'Vankar Interiors');
        expect(m.meetingDate, '17 May 2026');
        expect(m.status, F2fStatus.scheduled);

        expect(pageData.summary.totalMeetings, 1);
        expect(pageData.summary.scheduledCount, 1);
        expect(pageData.summary.completedCount, 0);
      }
    });

    test('MockF2fRepository handles get, submit, update and delete correctly', () async {
      final repo = MockF2fRepository();
      final initialData = await repo.getF2fData();
      expect(initialData.meetings.length, 1);
      expect(initialData.summary.totalMeetings, 1);

      // Submit new meeting
      final subRes = await repo.submitF2f(const F2fSubmissionPayload(
        toUser: 'USR00007',
        date: '2026-11-20',
        location: 'Starbucks Indiranagar',
        summary: 'Synergy discussion',
      ));
      expect(subRes['status'], 'success');

      final afterSubmit = await repo.getF2fData();
      expect(afterSubmit.meetings.length, 2);
      expect(afterSubmit.summary.totalMeetings, 2);

      // Update status
      final upRes = await repo.updateF2fStatus(const F2fStatusUpdatePayload(
        f2fCode: 'F2F0030',
        status: 'completed',
        summary: 'Concluded and deal closed',
      ));
      expect(upRes['status'], 'success');

      final afterUpdate = await repo.getF2fData();
      expect(afterUpdate.summary.completedCount, 1);

      // Delete meeting
      final delRes = await repo.deleteF2f('F2F0099');
      expect(delRes['status'], 'success');
      final afterDelete = await repo.getF2fData();
      expect(afterDelete.meetings.length, 1);
    });
  });

  group('F2fScreen and BottomSheet Widget Tests', () {
    testWidgets('F2fScreen displays header metrics and meeting card', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fDataProvider.overrideWith((ref) async => F2fPageData.baseline()),
          ],
          child: const MaterialApp(
            home: F2fScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text("1-to-1 Meetings (121's)"), findsOneWidget);
      expect(find.text("My 121's Networking Pipeline"), findsOneWidget);
      expect(find.text("Total 121's"), findsOneWidget);
      expect(find.text('Scheduled'), findsWidgets);
      expect(find.text('Completed'), findsWidgets);

      // Verify Meeting Card Details
      expect(find.text('Harri Kumar'), findsOneWidget);
      expect(find.text('Manjunath D'), findsOneWidget);
      expect(find.text('Vankar Interiors'), findsOneWidget);
      expect(find.text('17 May 2026'), findsOneWidget);
      expect(find.text('Spoke about business and I got quality referral'), findsOneWidget);
      expect(find.text('Update Status'), findsOneWidget);
      expect(find.text('Record 121 🤝'), findsOneWidget);
    });

    testWidgets('F2fScreen search query filters meeting records', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fDataProvider.overrideWith((ref) async => F2fPageData.baseline()),
          ],
          child: const MaterialApp(
            home: F2fScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Vankar Interiors'), findsOneWidget);

      // Search for non-existent meeting
      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'NonExistentPlace');
      await tester.pump();

      expect(find.text('Vankar Interiors'), findsNothing);
      expect(find.text('No 1-to-1 Meetings Recorded'), findsOneWidget);
    });

    testWidgets('F2fScreen status filter chips filter by status', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fDataProvider.overrideWith((ref) async => F2fPageData.baseline()),
          ],
          child: const MaterialApp(
            home: F2fScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Vankar Interiors'), findsOneWidget);

      // Tap 'Completed (0)' chip
      final completedChip = find.text('Completed (0)');
      await tester.tap(completedChip);
      await tester.pump();

      // Scheduled meeting is filtered out
      expect(find.text('Vankar Interiors'), findsNothing);
      expect(find.text('No 1-to-1 Meetings Recorded'), findsOneWidget);

      // Tap 'Scheduled (1)' chip
      final scheduledChip = find.text('Scheduled (1)');
      await tester.tap(scheduledChip);
      await tester.pump();

      expect(find.text('Vankar Interiors'), findsOneWidget);
    });

    testWidgets('F2fScreen renders cleanly on narrow Android (360x640) and iOS (390x844)', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fDataProvider.overrideWith((ref) async => F2fPageData.baseline()),
          ],
          child: const MaterialApp(
            home: F2fScreen(),
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

    testWidgets('AddF2fBottomSheet opens and validates required fields', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fRepositoryProvider.overrideWithValue(MockF2fRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AddF2fBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text("Record a 121's Meeting"), findsOneWidget);
      expect(find.text('Met With 👤 *'), findsOneWidget);
      expect(find.text('Meeting Date *'), findsOneWidget);
      expect(find.text('Location *'), findsOneWidget);

      final saveBtn = find.text("Save 121's Meeting");
      expect(saveBtn, findsOneWidget);
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please select a member'), findsOneWidget);
      expect(find.text('Enter location'), findsOneWidget);
    });

    testWidgets('UpdateF2fStatusSheet opens and displays status options', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const sampleMeeting = F2fMeetingItem(
        id: '1',
        f2fCode: 'F2F0030',
        fromMemberName: 'Harri Kumar',
        fromMemberEmail: 'harri@jobhunterr.com',
        toMemberName: 'Manjunath D',
        toMemberEmail: 'manjunath@vankarinteriors.com',
        location: 'Vankar Interiors',
        meetingDate: '17 May 2026',
        status: F2fStatus.scheduled,
        createdDate: '16 Oct 2026',
        summary: 'Discussion about flooring and interiors',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fRepositoryProvider.overrideWithValue(MockF2fRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UpdateF2fStatusSheet(meeting: sampleMeeting),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Change F2F Status'), findsOneWidget);
      expect(find.text('Meeting with Manjunath D'), findsOneWidget);
      expect(find.text('Select Meeting Status'), findsOneWidget);
      expect(find.text('Scheduled'), findsWidgets);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Confirm Status Update'), findsOneWidget);
    });

    testWidgets('F2fScreen displays error view on data failure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fDataProvider.overrideWith((ref) async => throw Exception('Connection lost to WINCO')),
          ],
          child: const MaterialApp(
            home: F2fScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Connection lost to WINCO'), findsOneWidget);
    });

    testWidgets('F2fScreen displays loading indicator during network fetch', (WidgetTester tester) async {
      final completer = Completer<F2fPageData>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            f2fDataProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: F2fScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(F2fPageData.baseline());
      await tester.pumpAndSettle();
    });
  });
}
