import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winco_connect/data/models/chapter_model.dart';
import 'package:winco_connect/data/models/member_dashboard_model.dart';
import 'package:winco_connect/features/chapters/presentation/my_chapter_screen.dart';
import 'package:winco_connect/features/chapters/presentation/all_chapters_screen.dart';
import 'package:winco_connect/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  group('Chapter Models & HTML Parsers', () {
    const sampleMyChapterHtml = '''
<!DOCTYPE html>
<html>
<body>
  <div class="chapter-card-pro">
    <h4>Winco - Jayanagar</h4>
    <span class="location-badge"><i class="fa fa-map-marker"></i> Jayanagar</span>
    <span class="chapter-status">Active</span>
    <div class="leader-box">
      <div class="leader-avatar"><img src="https://wincoconnect.com/assets/img/avatar.png"></div>
      <strong>Not Assigned</strong>
      <small>Assign leader to activate insights</small>
    </div>
  </div>
  <a href="https://wincoconnect.com/member/chapter/details/CHP0001">CHP0001</a>
  <h6>Total Members</h6>
  <p class="stat-value">36</p>
  <h6>Total Business Done</h6>
  <p class="stat-value">₹6,98,23,319</p>
  <h6>Total Referral</h6>
  <p class="stat-value">311</p>
  <h6>Total 121 Initiated</h6>
  <p class="stat-value">30</p>
  <h6>Total Visitors</h6>
  <p class="stat-value">1</p>
  <h6>Notifications</h6>
  <p class="stat-value">273</p>
  <div class="member-card">
    <a href="https://wincoconnect.com/member/profile/details/USR00001">
      <img src="https://wincoconnect.com/assets/img/m1.png" class="member-avatar">
      <h5 class="member-name">Harri Kumar</h5>
      <div class="chapter-badge">
        <i class="fa fa-building"></i>
        Civil Engineering
      </div>
    </a>
    Role: President
    <span>Ref</span><strong>25</strong>
    <span>Bus</span><strong>₹1,50,000</strong>
    <div class="member-contact">9876543210</div>
  </div>
</body>
</html>
''';

    const sampleAllChaptersHtml = '''
<!DOCTYPE html>
<html>
<body>
  <div class="chapter-card-pro">
    <a href="https://wincoconnect.com/member/chapter/details/CHP0001">CHP0001</a>
    <h4>Winco - Jayanagar</h4>
    <span class="location-badge"><i class="fa fa-map-marker"></i> Jayanagar</span>
    <span class="chapter-status">Active</span>
    <span>Members</span><h3>36</h3>
    <span>Business</span><h3>₹6,98,23,319</h3>
    <span>Ref</span><h5>311</h5>
    <span>Vis</span><h5>1</h5>
    <span>121</span><h5>30</h5>
  </div>
  <div class="chapter-card-pro">
    <a href="https://wincoconnect.com/member/chapter/details/CHP0002">CHP0002</a>
    <h4>Winco - JP Nagar</h4>
    <span class="location-badge"><i class="fa fa-map-marker"></i> JP Nagar</span>
    <span class="chapter-status">Active</span>
    <span>Members</span><h3>12</h3>
    <span>Business</span><h3>₹35,00,000</h3>
    <span>Ref</span><h5>15</h5>
    <span>Vis</span><h5>0</h5>
    <span>121</span><h5>5</h5>
  </div>
</body>
</html>
''';

    test('MyChapterPageData.fromHtml parses chapter header and stats correctly', () {
      final data = MyChapterPageData.fromHtml(sampleMyChapterHtml);
      expect(data.chapter.name, 'Winco - Jayanagar');
      expect(data.chapter.location, 'Jayanagar');
      expect(data.chapter.status, 'Active');
      expect(data.chapter.leaderName, 'Not Assigned');
      expect(data.totalMembers, 36);
      expect(data.totalBusiness, '₹6,98,23,319');
      expect(data.totalReferrals, 311);
      expect(data.total121s, 30);
      expect(data.totalVisitors, 1);
      expect(data.totalNotifications, 273);
      expect(data.members.length, 1);
      expect(data.members[0].name, 'Harri Kumar');
      expect(data.members[0].businessCategory, 'Civil Engineering');
      expect(data.members[0].role, 'President');
    });

    test('AllChaptersPageData.fromHtml parses platform summary and chapters correctly', () {
      final data = AllChaptersPageData.fromHtml(sampleAllChaptersHtml);
      expect(data.chapters.length, 2);
      expect(data.chapters[0].name, 'Winco - Jayanagar');
      expect(data.chapters[0].memberCount, 36);
      expect(data.chapters[1].name, 'Winco - JP Nagar');
      expect(data.chapters[1].memberCount, 12);
      expect(data.totalPlatformChapters, 2);
      expect(data.totalPlatformMembers, 48);
    });

    test('ChapterModel & ChapterMemberModel json serialization works', () {
      const member = ChapterMemberModel(
        id: 'USR001',
        name: 'Test Member',
        avatar: '',
        businessCategory: 'IT Consulting',
        role: 'Vice President',
        refCount: 10,
        businessAmount: '₹5,00,000',
        f2fCount: 5,
        visitorsCount: 2,
        contact: '9999999999',
        profileUrl: '/details/USR001',
      );
      final json = member.toJson();
      final revived = ChapterMemberModel.fromJson(json);
      expect(revived.name, 'Test Member');
      expect(revived.role, 'Vice President');
      expect(revived.refCount, 10);
    });
  });

  group('Chapter Screens UI Tests', () {
    testWidgets('MyChapterScreen renders properly with header, stats, and member list', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final baseData = MyChapterPageData.baseline();
      final testData = MyChapterPageData(
        chapter: baseData.chapter,
        totalMembers: baseData.totalMembers,
        totalBusiness: baseData.totalBusiness,
        totalReferrals: baseData.totalReferrals,
        total121s: baseData.total121s,
        totalVisitors: baseData.totalVisitors,
        totalNotifications: baseData.totalNotifications,
        members: baseData.members
            .map((m) => ChapterMemberModel(
                  id: m.id,
                  name: m.name,
                  avatar: '',
                  businessCategory: m.businessCategory,
                  role: m.role,
                  refCount: m.refCount,
                  businessAmount: m.businessAmount,
                  f2fCount: m.f2fCount,
                  visitorsCount: m.visitorsCount,
                  contact: m.contact,
                  profileUrl: m.profileUrl,
                ))
            .toList(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myChapterProvider.overrideWith((ref) async => testData),
          ],
          child: const MaterialApp(
            home: MyChapterScreen(),
          ),
        ),
      );

      // Verify AppBar title
      expect(find.text('My Chapter'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Chapter Name appears
      expect(find.text('Winco - Jayanagar'), findsWidgets);
      // Verify Chapter Members section title
      expect(find.text('Chapter Members'), findsOneWidget);
      // Verify Search bar
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('AllChaptersScreen renders platform banner and chapter list', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allChaptersProvider.overrideWith((ref) async => AllChaptersPageData.baseline()),
          ],
          child: const MaterialApp(
            home: AllChaptersScreen(),
          ),
        ),
      );

      // Verify AppBar title
      expect(find.text('All Chapters'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify platform banner numbers and titles
      expect(find.text('All Regional Chapters & Conclaves'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('6'), findsWidgets);
      // Verify search input
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Dashboard Drawer contains separate My Chapter and All Chapters entries', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDashboardProvider.overrideWith((ref) async => MemberDashboardData.baseline()),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open drawer
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify My Chapter and All Chapters appear as separate list tiles in the drawer
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('My Chapter')), findsOneWidget);
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('All Chapters')), findsOneWidget);
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('Roster')), findsOneWidget);
      expect(find.descendant(of: find.byType(Drawer), matching: find.text('6 Conclaves')), findsOneWidget);
    });
  });
}
