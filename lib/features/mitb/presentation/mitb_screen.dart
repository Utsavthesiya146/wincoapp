import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/mitb_model.dart';
import '../../../data/repositories/mitb_repository.dart';
import 'widgets/add_mitb_bottom_sheet.dart';

final mitbDataProvider = FutureProvider.autoDispose<MitbPageData>((ref) async {
  final repo = ref.watch(mitbRepositoryProvider);
  return await repo.getMitbData();
});

final mitbTabProvider = StateProvider.autoDispose<int>((ref) => 0); // 0: Received, 1: Given

class MitbScreen extends ConsumerWidget {
  const MitbScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mitbAsync = ref.watch(mitbDataProvider);
    final activeTab = ref.watch(mitbTabProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Business Done (MITB)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
            tooltip: 'Report Business Done',
            onPressed: () async {
              final submitted = await AddMitbBottomSheet.show(context);
              if (submitted == true) {
                ref.invalidate(mitbDataProvider);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Report MITB 💸',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final submitted = await AddMitbBottomSheet.show(context);
          if (submitted == true) {
            ref.invalidate(mitbDataProvider);
          }
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(mitbDataProvider);
          await ref.read(mitbDataProvider.future);
        },
        child: mitbAsync.when(
          data: (data) => _buildContent(context, ref, data, activeTab),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
          ),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(mitbDataProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MitbPageData data,
    int activeTab,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        // Summary Cards Section
        _buildSummaryHeader(data.summary),
        const SizedBox(height: 18),

        // Tabs Row (Business Received vs Business Given)
        _buildTabSelector(ref, data.summary, activeTab),
        const SizedBox(height: 14),

        // List View based on active tab
        if (activeTab == 0)
          _buildReceivedList(context, ref, data.receivedRecords)
        else
          _buildGivenList(context, ref, data.givenRecords),
      ],
    );
  }

  Widget _buildSummaryHeader(MitbSummary summary) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryBurgundy, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Money in the Bank (MITB)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Verified Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Official recorded business volume within WINCO',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Business Revenue',
                  value: summary.totalRevenue,
                  valueColor: AppColors.success,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Avg Member Value',
                  value: summary.avgMemberValue,
                  valueColor: AppColors.primaryBurgundy,
                  icon: Icons.insights,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Records',
                  value: summary.totalRecords.toString(),
                  valueColor: AppColors.accentOrange,
                  icon: Icons.receipt_long,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: valueColor),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(WidgetRef ref, MitbSummary summary, int activeTab) {
    return Container(
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
              ref: ref,
              label: 'Business Received',
              badgeCount: summary.receivedCount,
              badgeColor: AppColors.success,
              isSelected: activeTab == 0,
              onTap: () => ref.read(mitbTabProvider.notifier).state = 0,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabButton(
              ref: ref,
              label: 'Business Given',
              badgeCount: summary.givenCount,
              badgeColor: AppColors.primaryBurgundy,
              isSelected: activeTab == 1,
              onTap: () => ref.read(mitbTabProvider.notifier).state = 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required WidgetRef ref,
    required String label,
    required int badgeCount,
    required Color badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBurgundy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedList(
    BuildContext context,
    WidgetRef ref,
    List<MitbRecord> records,
  ) {
    if (records.isEmpty) {
      return const EmptyStateView(
        icon: Icons.savings_outlined,
        title: 'No Business Received',
        message: 'No closed business slips recorded as received yet.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildMitbRecordCard(context, record, isReceived: true);
      },
    );
  }

  Widget _buildGivenList(
    BuildContext context,
    WidgetRef ref,
    List<MitbRecord> records,
  ) {
    if (records.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBurgundy.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_outlined,
                size: 40,
                color: AppColors.primaryBurgundy,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Business Given Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have not reported closed business given to chapter members yet. Support your fellow members by submitting a slip.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () async {
                final submitted = await AddMitbBottomSheet.show(context);
                if (submitted == true) {
                  ref.invalidate(mitbDataProvider);
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Report Business Given'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildMitbRecordCard(context, record, isReceived: false);
      },
    );
  }

  Widget _buildMitbRecordCard(
    BuildContext context,
    MitbRecord record, {
    required bool isReceived,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Slip ID, Business Type, Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBurgundy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.id,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: record.businessType == 'New' ? AppColors.infoLight : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${record.businessType} Business',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: record.businessType == 'New' ? AppColors.info : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    record.date,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Flow Member Details: From -> To
          Row(
            children: [
              // From Member
              Expanded(
                child: _buildMemberInfoColumn(
                  label: 'From',
                  name: record.fromMemberName,
                  email: record.fromMemberEmail,
                  avatarUrl: record.fromMemberAvatar,
                ),
              ),

              // Arrow Indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primaryBurgundy,
                ),
              ),

              // To Member
              Expanded(
                child: _buildMemberInfoColumn(
                  label: 'To',
                  name: record.toMemberName,
                  email: record.toMemberEmail,
                  avatarUrl: record.toMemberAvatar,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Footer: Category & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  record.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                record.amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          if (record.description != null && record.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.description!,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberInfoColumn({
    required String label,
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildAvatar(name, avatarUrl),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          avatarUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(name),
        ),
      );
    }
    return _buildInitialsAvatar(name);
  }

  Widget _buildInitialsAvatar(String name) {
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryBurgundy.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBurgundy,
        ),
      ),
    );
  }
}
