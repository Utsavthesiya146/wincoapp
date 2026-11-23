import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/reports_model.dart';
import '../../../data/repositories/reports_repository.dart';

final reportsDataProvider = FutureProvider.autoDispose<ReportsPageData>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return await repo.getReportsData();
});

final reportsTabProvider = StateProvider.autoDispose<int>((ref) => 0);

class ReportsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const ReportsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late int _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Performance Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(reportsDataProvider);
          await ref.read(reportsDataProvider.future);
        },
        child: reportsAsync.when(
          data: (data) => _buildContent(context, data, _activeTab),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy)),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(reportsDataProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReportsPageData data, int activeTab) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Tab Selector Row
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: 'Participation',
                  isSelected: activeTab == 0,
                  onTap: () => setState(() => _activeTab = 0),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTabButton(
                  label: 'Fortnight Slips',
                  isSelected: activeTab == 1,
                  onTap: () => setState(() => _activeTab = 1),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildTabButton(
                  label: 'Top Performers',
                  isSelected: activeTab == 2,
                  onTap: () => setState(() => _activeTab = 2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active Tab View
        if (activeTab == 0) _buildParticipationTab(data),
        if (activeTab == 1) _buildWeeklySlipsTab(data),
        if (activeTab == 2) _buildTopPerformersTab(data),
      ],
    );
  }

  Widget _buildTabButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBurgundy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipationTab(ReportsPageData data) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Participation Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Cumulative scorecard across all networking activities', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              ...data.participationMetrics.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          e.value,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBurgundy),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySlipsTab(ReportsPageData data) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Forthnight Slips Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Slips passed and recorded for the current fortnight cycle', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              ...data.weeklySlips.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(s.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        Text(s.countOrAmount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBurgundy)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s.status, style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformersTab(ReportsPageData data) {
    return Column(
      children: [
        // 1. Overall Business Leaders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: AppColors.accentOrange, size: 20),
                  SizedBox(width: 8),
                  Text('Overall Business Leaders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...data.topBusiness.map((b) => _buildRankTile(b)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Overall Referral Leaders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_outlined, color: AppColors.primaryBurgundy, size: 20),
                  SizedBox(width: 8),
                  Text('Overall Referral Leaders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...data.topReferrals.map((r) => _buildRankTile(r)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. My Chapter Business Leaders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.apartment_rounded, color: AppColors.accentOrange, size: 20),
                  SizedBox(width: 8),
                  Text('My Chapter Business Leaders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              if (data.myChapterBusiness.isNotEmpty)
                ...data.myChapterBusiness.map((b) => _buildRankTile(b))
              else
                ...data.topBusiness.map((b) => _buildRankTile(b)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. My Chapter Referral Leaders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.groups_outlined, color: AppColors.primaryBurgundy, size: 20),
                  SizedBox(width: 8),
                  Text('My Chapter Referral Leaders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              if (data.myChapterReferrals.isNotEmpty)
                ...data.myChapterReferrals.map((r) => _buildRankTile(r))
              else
                ...data.topReferrals.map((r) => _buildRankTile(r)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankTile(TopPerformerItem item) {
    Color rankColor;
    if (item.rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (item.rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (item.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = AppColors.border;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (item.avatarUrl.isNotEmpty && item.avatarUrl.startsWith('http'))
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rankColor, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.5),
                child: Image.network(
                  item.avatarUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => _buildFallbackRankBadge(item.rank, rankColor),
                ),
              ),
            )
          else
            _buildFallbackRankBadge(item.rank, rankColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.memberName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(item.chapter, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            item.valueDisplay,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBurgundy),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackRankBadge(int rank, Color rankColor) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: rankColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }
}

