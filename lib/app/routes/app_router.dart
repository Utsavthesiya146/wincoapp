import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/authentication/presentation/member_login_screen.dart';
import '../../features/blogs/presentation/blog_detail_screen.dart';
import '../../features/blogs/presentation/blogs_screen.dart';
import '../../features/broadcast/presentation/broadcast_screen.dart';
import '../../features/chapters/presentation/all_chapters_screen.dart';
import '../../features/chapters/presentation/chapter_detail_screen.dart';
import '../../features/chapters/presentation/chapters_screen.dart';
import '../../features/chapters/presentation/my_chapter_screen.dart';
import '../../features/contact/presentation/contact_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/main_scaffold.dart';
import '../../features/f2f/presentation/f2f_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/invitations/presentation/invitations_screen.dart';
import '../../features/meetings/presentation/meetings_screen.dart';
import '../../features/members/presentation/member_directory_screen.dart';
import '../../features/members/presentation/member_profile_detail_screen.dart';
import '../../features/membership/presentation/join_community_registration_screen.dart';
import '../../features/membership/presentation/membership_registration_screen.dart';
import '../../features/membership/presentation/membership_status_screen.dart';
import '../../features/mitb/presentation/mitb_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/prime_club/presentation/prime_club_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/referrals/presentation/create_referral_screen.dart';
import '../../features/referrals/presentation/referral_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/visitors/presentation/visitors_screen.dart';
import '../../features/webview/presentation/webview_fallback_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // 0. Splash & Persistent Session Restoration
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 1. Home / Welcome Screen (App Launch)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // 2. Join Community Registration Screen (Verified Endpoint: POST /home/AddLead)
      GoRoute(
        path: '/register',
        builder: (context, state) => const JoinCommunityRegistrationScreen(),
      ),

      // 3. Member Login Screen (Verified Endpoint: POST /loginCheck)
      GoRoute(
        path: '/login',
        builder: (context, state) => const MemberLoginScreen(),
      ),

      // 4. About WINCO Connect Screen (Discovered from https://wincoconnect.com/#about)
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),

      // 5. Contact Support & Inquiries Screen (Verified Endpoint: POST /contact_save)
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),

      // 6. Blogs & Knowledge Hub Screen (Discovered from https://wincoconnect.com/blogs)
      GoRoute(
        path: '/blogs',
        builder: (context, state) => const BlogsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? 'BLOG-01';
              return BlogDetailScreen(blogId: id);
            },
          ),
        ],
      ),

      // 7. Chapters & Regional Network Screen (Discovered from https://wincoconnect.com/)
      GoRoute(
        path: '/chapters',
        builder: (context, state) => const ChaptersScreen(),
      ),

      // 8. Prime Club Access Screen (Discovered from https://wincoconnect.com/)
      GoRoute(
        path: '/prime-club',
        builder: (context, state) => const PrimeClubScreen(),
      ),

      // 9. Notifications Screen
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // 10. Member Profile Detail Screen (Resolves /members/:id, /member-profile/:id, and /member/profile/details/:id)
      GoRoute(
        path: '/members/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MemberProfileDetailScreen(memberId: id);
        },
      ),
      GoRoute(
        path: '/member/profile/details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MemberProfileDetailScreen(memberId: id);
        },
      ),
      GoRoute(
        path: '/member-profile/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MemberProfileDetailScreen(memberId: id);
        },
      ),

      // 11. Create Referral Screen
      GoRoute(
        path: '/create-referral',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final toMemberId = state.uri.queryParameters['toMemberId'];
          final toMemberName = state.uri.queryParameters['toMemberName'];
          return CreateReferralScreen(
            initialToMemberId: toMemberId,
            initialToMemberName: toMemberName,
          );
        },
      ),

      // 12. Authenticated Member Portal (Stateful Bottom Navigation Shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Member Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/members',
                builder: (context, state) => const MemberDirectoryScreen(),
              ),
            ],
          ),
          // Branch 2: Referrals
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/referrals',
                builder: (context, state) => const ReferralScreen(),
              ),
            ],
          ),
          // Branch 3: Business Done (MITB)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mitb',
                builder: (context, state) => const MitbScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // 13. Direct Member Routes
      GoRoute(
        path: '/member/mitb',
        builder: (context, state) => const MitbScreen(),
      ),

      // 15. Referrals / Connects Direct Routes
      GoRoute(
        path: '/member/connect',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/member/received_connects_report',
        builder: (context, state) => const ReferralScreen(),
      ),

      // 16. 1-to-1 Meetings (F2F / 121's) Direct Routes
      GoRoute(
        path: '/f2f',
        builder: (context, state) => const F2fScreen(),
      ),
      GoRoute(
        path: '/member/f2f',
        builder: (context, state) => const F2fScreen(),
      ),

      // 17. Chapter Meetings & Attendance
      GoRoute(
        path: '/meetings',
        builder: (context, state) => const MeetingsScreen(),
      ),
      GoRoute(
        path: '/member/meetings',
        builder: (context, state) => const MeetingsScreen(),
      ),
      GoRoute(
        path: '/member/my_attendance',
        builder: (context, state) => const MeetingsScreen(),
      ),

      // 18. Invitations
      GoRoute(
        path: '/invitations',
        builder: (context, state) => const InvitationsScreen(),
      ),
      GoRoute(
        path: '/member/invitations',
        builder: (context, state) => const InvitationsScreen(),
      ),

      // 19. Visitors Tracking
      GoRoute(
        path: '/visitors',
        builder: (context, state) => const VisitorsScreen(),
      ),
      GoRoute(
        path: '/member/visitor',
        builder: (context, state) => const VisitorsScreen(),
      ),

      // 20. Broadcast Messages
      GoRoute(
        path: '/broadcast',
        builder: (context, state) => const BroadcastScreen(),
      ),
      GoRoute(
        path: '/member/broadcast',
        builder: (context, state) => const BroadcastScreen(),
      ),

      // 21. Performance & Fortnight Slips Reports
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final t = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return ReportsScreen(initialTab: t);
        },
      ),
      GoRoute(
        path: '/member/reports/weekly_slips',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(initialTab: 1),
      ),
      GoRoute(
        path: '/member/topperformer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(initialTab: 2),
      ),
      GoRoute(
        path: '/member/my_participation_report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(initialTab: 0),
      ),

      // 21b. Membership Status & Application (Resolves /membership-status and /member/membership_status)
      GoRoute(
        path: '/membership-status',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MembershipStatusScreen(),
      ),
      GoRoute(
        path: '/member/membership_status',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MembershipStatusScreen(),
      ),
      GoRoute(
        path: '/membership-registration',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MembershipRegistrationScreen(),
      ),

      // 22. Community & Chapter Routes (Separated My Chapter and All Chapters)
      GoRoute(
        path: '/my-chapter',
        builder: (context, state) => const MyChapterScreen(),
      ),
      GoRoute(
        path: '/member/mychapter',
        builder: (context, state) => const MyChapterScreen(),
      ),
      GoRoute(
        path: '/all-chapters',
        builder: (context, state) => const AllChaptersScreen(),
      ),
      GoRoute(
        path: '/member/chapter',
        builder: (context, state) => const AllChaptersScreen(),
      ),
      GoRoute(
        path: '/chapter-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'CHP0001';
          return ChapterDetailScreen(chapterId: id);
        },
      ),
      GoRoute(
        path: '/member/chapter/details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'CHP0001';
          return ChapterDetailScreen(chapterId: id);
        },
      ),

      // 23. Profile & Member Details
      GoRoute(
        path: '/member/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/member/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // 24. Secure WebView Fallback for Web Registration & Login Integration
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? 'https://wincoconnect.com';
          final title = state.uri.queryParameters['title'] ?? 'WINCO Connect';
          return WebViewFallbackScreen(url: url, title: title);
        },
      ),
    ],
  );
});
