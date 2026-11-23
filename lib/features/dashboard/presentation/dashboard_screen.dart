import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/prime_badge.dart';
import '../../../data/models/member_dashboard_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/dashboard_repository.dart';
import 'widgets/business_report_graph_widget.dart';

/// Provider for authenticated member user model
final currentUserProvider = FutureProvider<MemberModel?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getCurrentUser();
});

/// Provider for active platform filter: 'all' (Lifetime), '180' (6 Months), '365' (12 Months)
final dashboardFilterProvider = StateProvider<String>((ref) => 'all');

/// Provider for authenticated member dashboard data
final memberDashboardProvider = FutureProvider<MemberDashboardData>((ref) async {
  final filter = ref.watch(dashboardFilterProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return await repo.getMemberDashboard(filter: filter);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _navigateToModule(BuildContext context, String path, String title) {
    if (path == '/member/mitb' || path == '/mitb') {
      context.push('/mitb');
      return;
    }
    if (path == '/member/connect' || path == '/referrals' || path == '/member/received_connects_report') {
      context.push('/referrals');
      return;
    }
    if (path == '/member/f2f' || path == '/f2f') {
      context.push('/f2f');
      return;
    }
    if (path == '/member/meetings' || path == '/member/my_attendance' || path == '/meetings') {
      context.push('/meetings');
      return;
    }
    if (path == '/member/invitations' || path == '/invitations') {
      context.push('/invitations');
      return;
    }
    if (path == '/member/visitor' || path == '/visitors') {
      context.push('/visitors');
      return;
    }
    if (path == '/member/broadcast' || path == '/broadcast') {
      context.push('/broadcast');
      return;
    }
    if (path == '/member/reports/weekly_slips' ||
        path == '/member/topperformer' ||
        path == '/member/my_participation_report' ||
        path == '/reports') {
      context.push('/reports');
      return;
    }
    if (path == '/member/mychapter' || path == '/my-chapter') {
      context.push('/my-chapter');
      return;
    }
    if (path == '/member/chapter' || path == '/all-chapters' || path == '/chapters') {
      context.push('/all-chapters');
      return;
    }
    if (path == '/member/profile' || path.startsWith('/member/profile/details') || path == '/profile') {
      context.push('/profile');
      return;
    }
    if (path == '/member/notifications' || path == '/notifications') {
      context.push('/notifications');
      return;
    }
    final fullUrl = 'https://wincoconnect.com$path';
    context.push(
      '/webview?url=${Uri.encodeComponent(fullUrl)}&title=${Uri.encodeComponent(title)}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(memberDashboardProvider);
    final activeFilter = ref.watch(dashboardFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      drawer: _buildAppDrawer(context, ref),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            AppLogo(size: 34),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.primaryBurgundy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentOrange,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notifications Action with Live Badge
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
                dashboardAsync.maybeWhen(
                  data: (data) => (data.personal.notifications ?? 0) > 0
                      ? Positioned(
                          right: -4,
                          top: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            child: Text(
                              '${data.personal.notifications ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            onPressed: () => context.push('/notifications'),
          ),

          // Logout Action
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to end your authenticated session?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBurgundy,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authRepositoryProvider).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(memberDashboardProvider);
        },
        child: dashboardAsync.when(
          data: (data) => _buildDashboardContent(context, ref, data, activeFilter),
          loading: () => _buildLoadingState(),
          error: (err, stack) => _buildErrorState(ref, err),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    MemberDashboardData data,
    String activeFilter,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Authenticated Member Welcome Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildWelcomeCard(context, data),
          ),

          const SizedBox(height: 20),

          // 2. Verified Quick Slips / Actions Hub
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickSlipsHub(context),
          ),

          const SizedBox(height: 24),

          // 3. Platform Performance Overview Banner (With Verified Filter Switcher)
          _buildPlatformOverviewSection(context, ref, data, activeFilter),

          const SizedBox(height: 24),

          // 4. Business Performance Dual-Series Performance Graph
          BusinessReportGraphWidget(
            chartData: data.chart,
            activeFilter: activeFilter,
            onFilterChanged: (newFilter) {
              ref.read(dashboardFilterProvider.notifier).state = newFilter;
            },
          ),

          const SizedBox(height: 24),

          // 5. Member-Specific Performance Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPersonalMetricsSection(context, data),
          ),

          const SizedBox(height: 24),

          // 5. Recent Meeting Details
          if (data.recentMeetings.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildRecentMeetingSection(context, data.recentMeetings.first),
            ),
            const SizedBox(height: 24),
          ],

          // 6. My Chapter Performance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildChapterPerformanceSection(context, data),
          ),

          const SizedBox(height: 24),

          // 7. Verified Portal Modules Directory
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildModulesDirectory(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, MemberDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.burgundyGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBurgundy.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.memberName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const PrimeBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 15, color: AppColors.accentOrange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Chapter: ${data.chapterName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.memberCode,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Profile Strength Indicator
          Builder(
            builder: (context) {
              final pDigits = data.personal.profileStrength.replaceAll(RegExp(r'[^\d.]'), '');
              final pDouble = double.tryParse(pDigits);
              final progressValue = pDouble != null ? (pDouble / 100.0).clamp(0.0, 1.0) : 0.0;
              final displayStrength = pDouble != null ? '${pDouble.toInt()}%' : 'Unavailable';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Profile Strength',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                displayStrength,
                                style: const TextStyle(
                                  color: AppColors.accentOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/member/profile/details/${data.memberCode}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Update', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSlipsHub(BuildContext context) {
    final actions = [
      {
        'title': 'Give MITB',
        'subtitle': 'Business Done',
        'icon': Icons.account_balance_wallet_outlined,
        'path': '/member/mitb',
        'color': const Color(0xFF2E7D32),
      },
      {
        'title': 'Give Referral',
        'subtitle': 'Pass Connect',
        'icon': Icons.send_rounded,
        'path': '/member/connect',
        'color': AppColors.accentOrange,
      },
      {
        'title': 'Record 121',
        'subtitle': 'Face-to-Face',
        'icon': Icons.handshake_outlined,
        'path': '/member/f2f',
        'color': AppColors.primaryBurgundy,
      },
      {
        'title': 'Invite Guest',
        'subtitle': 'Send Invite',
        'icon': Icons.person_add_alt_1_outlined,
        'path': '/member/invitations',
        'color': const Color(0xFF1565C0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Slips & Actions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((act) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _navigateToModule(
                  context,
                  act['path'] as String,
                  act['title'] as String,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (act['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          act['icon'] as IconData,
                          size: 20,
                          color: act['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        act['title'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        act['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlatformOverviewSection(
    BuildContext context,
    WidgetRef ref,
    MemberDashboardData data,
    String activeFilter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'WINCO Platform Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Verified Filter Switcher (All 5 Website Parameters: 7, 30, 180, 365, all)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(ref, '15D', '7', activeFilter),
                      _buildFilterChip(ref, '1M', '30', activeFilter),
                      _buildFilterChip(ref, '6M', '180', activeFilter),
                      _buildFilterChip(ref, '12M', '365', activeFilter),
                      _buildFilterChip(ref, 'All', 'all', activeFilter),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Live Platform Ticker Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accentOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Verified Live Ticker: Business Done ${data.platform.businessDone} • ${data.platform.referrals} Referrals • ${data.platform.members} Members • ${data.platform.chapters} Chapters',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A3412),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 4 Key Platform Metric Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            children: [
              _buildStatMetricCard(
                title: 'Total Business Done',
                value: data.platform.businessDone,
                icon: Icons.trending_up,
                color: const Color(0xFF2E7D32),
                subtitle: 'Platform Total',
                onTap: () => _navigateToModule(context, '/member/mitb', 'Business Done'),
              ),
              _buildStatMetricCard(
                title: 'Total Referrals',
                value: '${data.platform.referrals}',
                icon: Icons.share_outlined,
                color: AppColors.accentOrange,
                subtitle: 'Exchanged slips',
                onTap: () => _navigateToModule(context, '/member/connect', 'Referral Given'),
              ),
              _buildStatMetricCard(
                title: 'Active Members',
                value: '${data.platform.members}',
                icon: Icons.people_alt_outlined,
                color: AppColors.primaryBurgundy,
                subtitle: 'Verified Leaders',
                onTap: () => _navigateToModule(context, '/member/mychapter', 'My Chapter'),
              ),
              _buildStatMetricCard(
                title: 'Regional Chapters',
                value: '${data.platform.chapters}',
                icon: Icons.corporate_fare_outlined,
                color: const Color(0xFF1565C0),
                subtitle: 'Across Network',
                onTap: () => _navigateToModule(context, '/member/chapter', 'All Chapters'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String value, String current) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => ref.read(dashboardFilterProvider.notifier).state = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBurgundy : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalMetricsSection(BuildContext context, MemberDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'My Business Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              data.memberName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildStatMetricCard(
              title: 'Business Received',
              value: data.personal.businessReceived,
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFF2E7D32),
              subtitle: 'From network',
              onTap: () => _navigateToModule(context, '/member/mitb', 'Business Received'),
            ),
            _buildStatMetricCard(
              title: 'Business Given',
              value: data.personal.businessGiven,
              icon: Icons.arrow_upward_rounded,
              color: AppColors.primaryBurgundy,
              subtitle: 'To network',
              onTap: () => _navigateToModule(context, '/member/mitb', 'Business Given'),
            ),
            _buildStatMetricCard(
              title: 'Referral Given',
              value: data.personal.referralsGiven != null ? '${data.personal.referralsGiven}' : 'Unavailable',
              icon: Icons.upload_outlined,
              color: AppColors.accentOrange,
              subtitle: 'Outbound slips',
              onTap: () => _navigateToModule(context, '/member/connect', 'Referral Given'),
            ),
            _buildStatMetricCard(
              title: 'Referral Received',
              value: data.personal.referralsReceived != null ? '${data.personal.referralsReceived}' : 'Unavailable',
              icon: Icons.download_outlined,
              color: const Color(0xFF1565C0),
              subtitle: 'Inbound slips',
              onTap: () => _navigateToModule(context, '/member/received_connects_report', 'Received Referrals'),
            ),
            _buildStatMetricCard(
              title: 'Meetings Attended',
              value: data.personal.meetings != null ? '${data.personal.meetings}' : 'Unavailable',
              icon: Icons.event_available_outlined,
              color: const Color(0xFF6A1B9A),
              subtitle: 'Chapter meetings',
              onTap: () => _navigateToModule(context, '/member/meetings', 'Meetings'),
            ),
            _buildStatMetricCard(
              title: 'Visitors',
              value: data.personal.visitors != null ? '${data.personal.visitors}' : 'Unavailable',
              icon: Icons.group_outlined,
              color: const Color(0xFF5D4037),
              subtitle: 'Invited guests',
              onTap: () => _navigateToModule(context, '/member/visitor', 'Visitors'),
            ),
            _buildStatMetricCard(
              title: '121 Initiated By Me',
              value: data.personal.oneToOneByMe != null ? '${data.personal.oneToOneByMe}' : 'Unavailable',
              icon: Icons.forum_outlined,
              color: const Color(0xFF00838F),
              subtitle: 'Outbound 121s',
              onTap: () => _navigateToModule(context, '/member/f2f', "121's"),
            ),
            _buildStatMetricCard(
              title: '121 Initiated With Me',
              value: data.personal.oneToOneWithMe != null ? '${data.personal.oneToOneWithMe}' : 'Unavailable',
              icon: Icons.people_outline,
              color: const Color(0xFF00796B),
              subtitle: 'Inbound 121s',
              onTap: () => _navigateToModule(context, '/member/f2f', "121's"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentMeetingSection(BuildContext context, RecentMeetingItem meeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Recent Meeting Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _navigateToModule(context, '/member/meetings', 'All Meetings'),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    meeting.number,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.event,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.accentOrange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            meeting.chapter,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${meeting.date} • ${meeting.time}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToModule(context, '/member/meetings', 'Meetings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.primaryBurgundy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterPerformanceSection(BuildContext context, MemberDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'My Chapter Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _navigateToModule(context, '/member/mychapter', 'My Chapter Roster'),
              child: const Text(
                'View Roster',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildChapterStatItem('Total Members', data.chapter.totalMembers != null ? '${data.chapter.totalMembers}' : 'Unavailable', Icons.people_outline),
                  _buildChapterStatItem('Total Business', data.chapter.totalBusiness, Icons.currency_rupee),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  _buildChapterStatItem('Total Referrals', data.chapter.totalReferrals != null ? '${data.chapter.totalReferrals}' : 'Unavailable', Icons.share_outlined),
                  _buildChapterStatItem('121 Initiated', data.chapter.oneToOnes != null ? '${data.chapter.oneToOnes}' : 'Unavailable', Icons.forum_outlined),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryBurgundy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesDirectory(BuildContext context) {
    final modules = [
      {'title': 'My Chapter Roster', 'path': '/member/mychapter', 'icon': Icons.groups_outlined},
      {'title': 'All Chapters', 'path': '/member/chapter', 'icon': Icons.apartment_rounded},
      {'title': 'Top Performers', 'path': '/member/topperformer', 'icon': Icons.emoji_events_outlined},
      {'title': 'Chapter Meetings', 'path': '/member/meetings', 'icon': Icons.calendar_month_outlined},
      {'title': '1-to-1 Meetings (121\'s)', 'path': '/member/f2f', 'icon': Icons.handshake_outlined},
      {'title': 'Visitor Tracking', 'path': '/member/visitor', 'icon': Icons.person_search_outlined},
      {'title': 'My Attendance', 'path': '/member/my_attendance', 'icon': Icons.fact_check_outlined},
      {'title': 'Broadcast Messages', 'path': '/member/broadcast', 'icon': Icons.campaign_outlined},
      {'title': 'Performance Reports', 'path': '/reports', 'icon': Icons.insights_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Authenticated Modules',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
            itemBuilder: (context, index) {
              final mod = modules[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundy.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(mod['icon'] as IconData, size: 20, color: AppColors.primaryBurgundy),
                ),
                title: Text(
                  mod['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textSecondary),
                onTap: () => _navigateToModule(
                  context,
                  mod['path'] as String,
                  mod['title'] as String,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.textSecondary),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryBurgundy),
          SizedBox(height: 16),
          Text(
            'Retrieving verified member metrics...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ErrorView(
          message: 'Failed to load member dashboard: ${err.toString()}',
          onRetry: () => ref.invalidate(memberDashboardProvider),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    final memberName = currentUserAsync.maybeWhen(
      data: (user) => (user != null && user.fullName.isNotEmpty) ? user.fullName : null,
      orElse: () => null,
    ) ?? 'WINCO Member';

    final company = currentUserAsync.maybeWhen(
      data: (user) => (user != null && user.businessName.isNotEmpty) ? user.businessName : null,
      orElse: () => null,
    ) ?? 'WINCO Prime Network';

    final avatarUrl = currentUserAsync.maybeWhen(
      data: (user) => (user != null && user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
          ? user.profileImageUrl
          : null,
      orElse: () => null,
    );

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBurgundy,
                  Color(0xFF4A1010),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentOrange, width: 2),
                  ),
                  child: ClipOval(
                    child: (avatarUrl != null)
                        ? Image.network(
                            avatarUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                memberName.isNotEmpty ? memberName[0].toUpperCase() : 'W',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBurgundy,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              memberName.isNotEmpty ? memberName[0].toUpperCase() : 'W',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBurgundy,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        memberName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        company,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      const PrimeBadge(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.trending_up_rounded,
                  title: 'Business (MITB)',
                  badge: 'Slip',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/mitb');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.share_rounded,
                  title: 'Referrals (Connect)',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/referrals');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people_outline_rounded,
                  title: '1-to-1 Meetings (F2F)',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/f2f');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event_note_rounded,
                  title: 'Meetings & Attendance',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/meetings');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.mail_outline_rounded,
                  title: 'Guest Invitations',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/invitations');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.badge_outlined,
                  title: 'Visitors Tracking',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/visitors');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.groups_rounded,
                  title: 'My Chapter',
                  badge: 'Roster',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/my-chapter');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.apartment_rounded,
                  title: 'All Chapters',
                  badge: '6 Conclaves',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/all-chapters');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Broadcasts',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/broadcast');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assessment_outlined,
                  title: 'Reports & Top Performers',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/reports');
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/notifications');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            subtitle: const Text(
              'Version ${AppConstants.appVersion}+${AppConstants.appBuildNumber}',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to end your authenticated session?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBurgundy,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authRepositoryProvider).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 6),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(icon, color: AppColors.primaryBurgundy, size: 21),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
