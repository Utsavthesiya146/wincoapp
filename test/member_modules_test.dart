import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winco_connect/data/models/meeting_model.dart';
import 'package:winco_connect/data/models/invitation_model.dart';
import 'package:winco_connect/data/models/visitor_model.dart';
import 'package:winco_connect/data/models/reports_model.dart';
import 'package:winco_connect/data/repositories/meeting_repository.dart';
import 'package:winco_connect/data/repositories/invitation_repository.dart';
import 'package:winco_connect/data/repositories/visitor_repository.dart';
import 'package:winco_connect/data/repositories/reports_repository.dart';
import 'package:winco_connect/features/meetings/presentation/meetings_screen.dart';
import 'package:winco_connect/features/invitations/presentation/invitations_screen.dart';
import 'package:winco_connect/features/visitors/presentation/visitors_screen.dart';
import 'package:winco_connect/features/broadcast/presentation/broadcast_screen.dart';
import 'package:winco_connect/features/reports/presentation/reports_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:winco_connect/data/models/member_model.dart';
import 'package:winco_connect/data/repositories/member_repository.dart';
import 'package:winco_connect/features/members/presentation/member_profile_detail_screen.dart';
import 'package:winco_connect/app/routes/app_router.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  group('Chapter Meetings & Attendance Models', () {
    test('MeetingSubmissionPayload generates valid FormData map', () {
      const payload = MeetingSubmissionPayload(
        chapterCode: 'CHP0001',
        title: 'Executive Chapter Assembly',
        date: '2026-11-20',
        time: '07:30:00',
        venue: 'The Grand Ballroom, Bengaluru',
        description: 'Bi-weekly business networking and slip exchange.',
      );

      final map = payload.toFormData();
      expect(map['chapter_code'], 'CHP0001');
      expect(map['title'], 'Executive Chapter Assembly');
      expect(map['date'], '2026-11-20');
      expect(map['time'], '07:30:00');
      expect(map['venue'], 'The Grand Ballroom, Bengaluru');
      expect(map['description'], 'Bi-weekly business networking and slip exchange.');
    });

    test('MeetingsPageData parses sample meetings and attendance HTML table', () {
      const sampleMeetingsHtml = '''
        <table>
          <tbody>
            <tr>
              <td>1</td>
              <td>14 Nov 2026 07:30 AM</td>
              <td>Breakfast Networking Meet</td>
              <td>Winco - Jayanagar</td>
              <td>Hotel Chancery Pavilion</td>
              <td>Offline</td>
              <td>Completed</td>
              <td></td>
            </tr>
          </tbody>
        </table>
      ''';

      const sampleAttendanceHtml = '''
        <table>
          <tbody>
            <tr>
              <td>Breakfast Networking Meet</td>
              <td>Winco - Jayanagar</td>
              <td>14 Nov 2026</td>
              <td>Present</td>
            </tr>
          </tbody>
        </table>
      ''';

      final pageData = MeetingsPageData.fromHtml(sampleMeetingsHtml, sampleAttendanceHtml);
      expect(pageData.meetings.length, 1);
      expect(pageData.meetings.first.eventTitle, 'Breakfast Networking Meet');
      expect(pageData.meetings.first.location, 'Hotel Chancery Pavilion');
      expect(pageData.attendance.length, 1);
      expect(pageData.attendance.first.status, 'Present');
    });

    test('MockMeetingRepository delivers realistic data', () async {
      final repo = MockMeetingRepository();
      final pageData = await repo.getMeetingsData();

      expect(pageData.meetings.isNotEmpty, isTrue);
      expect(pageData.attendance.isNotEmpty, isTrue);

      final result = await repo.submitMeeting(
        const MeetingSubmissionPayload(
          chapterCode: 'CHP0001',
          title: 'Test Meet',
          date: '2026-12-01',
          time: '08:00:00',
          venue: 'Club House',
          description: 'Monthly sync',
        ),
      );
      expect(result['status'], 'success');
    });
  });

  group('Invitations Models and Repository', () {
    test('InvitationSubmissionPayload toFormData creates valid POST payload', () {
      const payload = InvitationSubmissionPayload(
        guestName: 'Rajesh Sharma',
        guestPhone: '9876543210',
        guestEmail: 'rajesh.sharma@example.com',
        guestCompany: 'Apex Technologies',
        message: 'Join us for business networking',
      );

      final map = payload.toFormData();
      expect(map['guest_name'], 'Rajesh Sharma');
      expect(map['guest_phone'], '9876543210');
      expect(map['guest_email'], 'rajesh.sharma@example.com');
      expect(map['guest_company'], 'Apex Technologies');
      expect(map['message'], 'Join us for business networking');
    });

    test('MockInvitationRepository creates and lists invitations', () async {
      final repo = MockInvitationRepository();
      final initialData = await repo.getInvitationsData();
      final initialCount = initialData.invitations.length;

      final res = await repo.submitInvitation(
        const InvitationSubmissionPayload(
          guestName: 'Anil Kumar',
          guestPhone: '9988776655',
          guestEmail: 'anil@example.com',
          guestCompany: 'Kumar Logistics',
          message: 'Cordially invited to our chapter meet',
        ),
      );
      expect(res['status'], 'success');

      final updatedData = await repo.getInvitationsData();
      expect(updatedData.invitations.length, initialCount + 1);
      expect(updatedData.invitations.first.guestName, 'Anil Kumar');
    });
  });

  group('Visitors Tracking Models and Repository', () {
    test('VisitorSubmissionPayload toFormData creates valid POST payload', () {
      const payload = VisitorSubmissionPayload(
        visitorName: 'Deepak Verma',
        phone: '9123456780',
        email: 'deepak@verma.com',
        company: 'Verma Interiors',
        dateVisited: '2026-11-21',
      );

      final map = payload.toFormData();
      expect(map['visitor_name'], 'Deepak Verma');
      expect(map['phone'], '9123456780');
      expect(map['email'], 'deepak@verma.com');
      expect(map['company'], 'Verma Interiors');
      expect(map['date_visited'], '2026-11-21');
    });

    test('MockVisitorRepository creates and lists visitors', () async {
      final repo = MockVisitorRepository();
      final initialData = await repo.getVisitorsData();
      final initialCount = initialData.visitors.length;

      final res = await repo.submitVisitor(
        const VisitorSubmissionPayload(
          visitorName: 'Sunita Reddy',
          phone: '9845012345',
          email: 'sunita@reddy.com',
          company: 'Reddy Legal Advisory',
          dateVisited: '2026-11-21',
        ),
      );
      expect(res['status'], 'success');

      final updatedData = await repo.getVisitorsData();
      expect(updatedData.visitors.length, initialCount + 1);
      expect(updatedData.visitors.first.visitorName, 'Sunita Reddy');
    });
  });

  group('Reports & Analytics Models and Repository', () {
    test('ReportsPageData parses sample slip data', () {
      const sampleHtml = '''
        <table>
          <tbody>
            <tr>
              <td>Connects Given</td>
              <td>12</td>
              <td>Recorded</td>
            </tr>
          </tbody>
        </table>
      ''';

      final pageData = ReportsPageData.fromHtml(sampleHtml);
      expect(pageData.weeklySlips.length, 1);
      expect(pageData.weeklySlips.first.category, 'Connects Given');
      expect(pageData.weeklySlips.first.countOrAmount, '12');
    });

    test('MockReportsRepository retrieves mock analytics data', () async {
      final repo = MockReportsRepository();
      final data = await repo.getReportsData();

      expect(data.weeklySlips.isNotEmpty, isTrue);
      expect(data.topBusiness.isNotEmpty, isTrue);
      expect(data.topReferrals.isNotEmpty, isTrue);
      expect(data.participationMetrics.isNotEmpty, isTrue);
    });
  });

  group('Module Presentation & Screen Widget Tests', () {
    testWidgets('MeetingsScreen displays tabs and meeting items', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            meetingRepositoryProvider.overrideWithValue(MockMeetingRepository()),
          ],
          child: const MaterialApp(
            home: MeetingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Chapter Meetings & Attendance'), findsOneWidget);
      expect(find.textContaining('Chapter Meetings'), findsWidgets);
      expect(find.textContaining('My Attendance'), findsWidgets);
      expect(find.text('Project Collaboration Kumbalgodu'), findsOneWidget);
    });

    testWidgets('InvitationsScreen displays invitations and send button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            invitationRepositoryProvider.overrideWithValue(MockInvitationRepository()),
          ],
          child: const MaterialApp(
            home: InvitationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Guest Invitations'), findsOneWidget);
      expect(find.text('Invite Guest'), findsOneWidget);
      expect(find.text('No Invitations Found'), findsOneWidget);
    });

    testWidgets('VisitorsScreen displays visitor logs and register button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            visitorRepositoryProvider.overrideWithValue(MockVisitorRepository()),
          ],
          child: const MaterialApp(
            home: VisitorsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Visitors Tracking'), findsOneWidget);
      expect(find.text('Add Visitor'), findsOneWidget);
      expect(find.text('No Visitors Found'), findsOneWidget);
    });

    testWidgets('BroadcastScreen displays announcements and search bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BroadcastScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Broadcast Messages'), findsOneWidget);
      expect(find.text('Community Broadcasts'), findsOneWidget);
      expect(find.text('No Broadcast Messages'), findsOneWidget);
    });

    testWidgets('ReportsScreen displays reports tabs and slip data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportsRepositoryProvider.overrideWithValue(MockReportsRepository()),
          ],
          child: const MaterialApp(
            home: ReportsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Performance Reports'), findsOneWidget);
      expect(find.text('Participation'), findsOneWidget);
      expect(find.text('Fortnight Slips'), findsOneWidget);
      expect(find.text('Top Performers'), findsOneWidget);
    });
  });

  group('Member Directory & Profile Navigation & Parity Tests', () {
    test('MemberModel supports website and JSON serialization', () {
      const member = MemberModel(
        id: 'USR00001',
        firstName: 'Harri',
        lastName: 'Kumar',
        email: 'harri@jobhunterr.com',
        phone: '9341873532',
        businessName: 'Hosting Baba',
        businessCategory: 'Growth Marketing Partner',
        since: '2024',
        location: 'Winco - Jayanagar',
        chapterId: '1',
        chapterName: 'Winco - Jayanagar',
        profileImageUrl: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
        designation: 'Growth Marketing Partner',
        about: 'Website Development and Digital Marketing are essential for business growth.',
        website: 'https://webhostingbaba.com',
      );

      final json = member.toJson();
      expect(json['id'], 'USR00001');
      expect(json['business_name'], 'Hosting Baba');
      expect(json['business_category'], 'Growth Marketing Partner');
      expect(json['website'], 'https://webhostingbaba.com');

      final revived = MemberModel.fromJson(json);
      expect(revived.id, 'USR00001');
      expect(revived.fullName, 'Harri Kumar');
      expect(revived.website, 'https://webhostingbaba.com');
    });

    test('MemberModel.fromProfileHtml correctly parses real website profile dump', () {
      final dumpFile = File('test/fixtures/profile_dump.html');
      if (dumpFile.existsSync()) {
        final html = dumpFile.readAsStringSync();
        final member = MemberModel.fromProfileHtml(html, fallbackEmail: 'harri@jobhunterr.com');
        expect(member.id, 'USR00001');
        expect(member.fullName, 'Harri Kumar');
        expect(member.businessName, 'Hosting Baba');
        expect(member.profileImageUrl, contains('uploads/profile/'));
        expect(member.referralsGiven, 0);
        expect(member.referralsReceived, 0);
        expect(member.meetingsAttended, 31);
        expect(member.website, 'https://webhostingbaba.com');
        expect(member.about, contains('Website Development and Digital Marketing'));
      }
    });

    test('GoRouter contains registered routes for /members/:id and /member/profile/details/:id', () {
      final container = ProviderContainer(
        overrides: [
          memberRepositoryProvider.overrideWithValue(MockMemberRepository()),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      final routes = router.configuration.routes;

      final paths = <String>[];
      void collectPaths(List<RouteBase> rList) {
        for (final r in rList) {
          if (r is GoRoute) {
            paths.add(r.path);
            collectPaths(r.routes);
          } else if (r is StatefulShellRoute) {
            for (final branch in r.branches) {
              collectPaths(branch.routes);
            }
          }
        }
      }
      collectPaths(routes);

      expect(paths.contains('/members/:id'), isTrue);
      expect(paths.contains(':id'), isTrue); // child route under /members in StatefulShellBranch
      expect(paths.contains('/member/profile/details/:id'), isTrue);
      expect(paths.contains('/member-profile/:id'), isTrue);
    });

    testWidgets('GoRouter successfully navigates to /members/USR00001 without GoException', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const member = MemberModel(
        id: 'USR00001',
        firstName: 'Harri',
        lastName: 'Kumar',
        email: 'harri@jobhunterr.com',
        phone: '9341873532',
        businessName: 'Hosting Baba',
        businessCategory: 'Growth Marketing Partner',
        since: '2024',
        location: 'Bengaluru',
        chapterId: '1',
        chapterName: 'Winco - Jayanagar',
        profileImageUrl: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
      );

      final container = ProviderContainer(
        overrides: [
          memberDetailProvider('USR00001').overrideWith((ref) => Future.value(member)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Navigate directly to /members/USR00001
      router.go('/members/USR00001');
      await tester.pumpAndSettle();

      // Verified: no Page Not Found or GoException
      expect(find.text('Page Not Found'), findsNothing);
      expect(find.textContaining('GoException'), findsNothing);
      expect(find.text('Harri Kumar'), findsOneWidget);
    });

    test('LiveMemberRepository card parsing accurately parses real HTML dump', () {
      const sampleCardHtml = '''
        <div class="member-card">
          <a href="https://wincoconnect.com/member/profile/details/USR00001">
            <div class="member-top text-center">
              <img
                style="object-fit: cover; object-position: top center;"
                src="https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg"
                class="member-avatar">
              <h5 class="member-name">Harri Kumar</h5>
              <h6 syle="font-size:12px;"></h6>
              <div class="chapter-badge">
                <i class="fa fa-building"></i>
                <!-- Winco - Jayanagar  -->
                Growth Marketing Partner
              </div>
            </div>
            <div class="member-role-box">Role: member</div>
            <div class="member-stats">
              <div class="stat-box"><span>Ref</span><strong>5</strong></div>
              <div class="stat-box"><span>Bus</span><strong>₹50,000</strong></div>
              <div class="stat-box"><span>121's</span><strong>2</strong></div>
              <div class="stat-box"><span>VIS</span><strong>1</strong></div>
            </div>
            <div class="member-contact">
              <i class="fa fa-phone"></i>
              9341873532
            </div>
          </a>
        </div>
      ''';

      final members = LiveMemberRepository.parseMembersFromHtml(sampleCardHtml);

      expect(members.length, 1);
      final m = members.first;
      expect(m.id, 'USR00001');
      expect(m.fullName, 'Harri Kumar');
      expect(m.profileImageUrl, 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg');
      expect(m.businessName, 'Hosting Baba');
      expect(m.businessCategory, 'Growth Marketing Partner');
      expect(m.chapterName, 'Winco - Jayanagar');
      expect(m.phone, '9341873532');
      expect(m.referralsGiven, 5);
      expect(m.businessDone, 50000.0);
    });

    testWidgets('MemberProfileDetailScreen displays photo avatar, business, category, and chapter', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const member = MemberModel(
        id: 'USR00001',
        firstName: 'Harri',
        lastName: 'Kumar',
        email: 'harri@jobhunterr.com',
        phone: '9341873532',
        businessName: 'Hosting Baba',
        businessCategory: 'Growth Marketing Partner',
        since: '2024',
        location: 'Bengaluru',
        chapterId: '1',
        chapterName: 'Winco - Jayanagar',
        profileImageUrl: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
        website: 'https://webhostingbaba.com',
        about: 'Website Development and Digital Marketing are essential for business growth.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDetailProvider('USR00001').overrideWith((ref) => Future.value(member)),
          ],
          child: const MaterialApp(
            home: MemberProfileDetailScreen(memberId: 'USR00001'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Harri Kumar'), findsOneWidget);
      expect(find.text('Hosting Baba'), findsNWidgets(2)); // in header + business info row
      expect(find.text('Growth Marketing Partner'), findsNWidgets(2)); // in header + category row
      expect(find.text('Winco - Jayanagar'), findsNWidgets(2)); // in header + chapter row
      expect(find.text('https://webhostingbaba.com'), findsOneWidget);
    });
  });
}
