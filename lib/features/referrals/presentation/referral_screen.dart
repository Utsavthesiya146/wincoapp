import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/referral_model.dart';
import '../../../data/repositories/referral_repository.dart';
import 'widgets/add_referral_bottom_sheet.dart';
import 'widgets/update_referral_status_sheet.dart';

final referralDataProvider = FutureProvider.autoDispose<ReferralPageData>((ref) async {
  final repo = ref.watch(referralRepositoryProvider);
  return await repo.getConnectData();
});

final referralTabProvider = StateProvider.autoDispose<int>((ref) => 0); // 0: Received, 1: Given
final referralStatusFilterProvider = StateProvider.autoDispose<String>((ref) => 'all');

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectAsync = ref.watch(referralDataProvider);
    final activeTab = ref.watch(referralTabProvider);
    final statusFilter = ref.watch(referralStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Business Referrals',
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
            tooltip: 'Pass Referral',
            onPressed: () async {
              final submitted = await AddReferralBottomSheet.show(context);
              if (submitted == true) {
                ref.invalidate(referralDataProvider);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.send_rounded),
        label: const Text(
          'Pass Connect 🤝',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final submitted = await AddReferralBottomSheet.show(context);
          if (submitted == true) {
            ref.invalidate(referralDataProvider);
          }
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(referralDataProvider);
          await ref.read(referralDataProvider.future);
        },
        child: connectAsync.when(
          data: (data) => _buildContent(context, ref, data, activeTab, statusFilter),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
          ),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(referralDataProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ReferralPageData data,
    int activeTab,
    String statusFilter,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        // Summary Performance Card
        _buildSummaryHeader(data.summary),
        const SizedBox(height: 18),

        // Tabs Selector (Received vs Given)
        _buildTabSelector(ref, data.summary, activeTab),
        const SizedBox(height: 14),

        // Status Filter Chips (For Received Referrals)
        if (activeTab == 0) ...[
          _buildStatusFilterRow(ref, statusFilter),
          const SizedBox(height: 14),
        ],

        // Referrals Content List
        if (activeTab == 0)
          _buildReceivedList(context, ref, data.receivedReferrals, statusFilter)
        else
          _buildGivenList(context, ref, data.givenReferrals),
      ],
    );
  }

  Widget _buildSummaryHeader(ReferralSummary summary) {
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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.handshake_outlined, color: AppColors.primaryBurgundy, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Referral Connects Pipeline',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
            'Official business leads passed within WINCO Connect',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Referrals',
                  value: summary.totalReferrals.toString(),
                  valueColor: AppColors.primaryBurgundy,
                  icon: Icons.hub_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Received',
                  value: summary.receivedCount.toString(),
                  valueColor: AppColors.success,
                  icon: Icons.call_received_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Given',
                  value: summary.givenCount.toString(),
                  valueColor: AppColors.accentOrange,
                  icon: Icons.call_made_rounded,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
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

  Widget _buildTabSelector(WidgetRef ref, ReferralSummary summary, int activeTab) {
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
              key: const Key('referral_received_tab'),
              label: 'Received',
              badgeCount: summary.receivedCount,
              badgeColor: AppColors.success,
              isSelected: activeTab == 0,
              onTap: () => ref.read(referralTabProvider.notifier).state = 0,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabButton(
              key: const Key('referral_given_tab'),
              label: 'Given',
              badgeCount: summary.givenCount,
              badgeColor: AppColors.accentOrange,
              isSelected: activeTab == 1,
              onTap: () => ref.read(referralTabProvider.notifier).state = 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    Key? key,
    required String label,
    required int badgeCount,
    required Color badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
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
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
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

  Widget _buildStatusFilterRow(WidgetRef ref, String activeFilter) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'open for discussion', 'label': 'Open For Discussion'},
      {'key': 'contacted', 'label': 'Contacted'},
      {'key': 'not converted', 'label': 'Need Sometime'},
      {'key': 'business done', 'label': 'Business Done'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryBurgundy,
              backgroundColor: AppColors.white,
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? AppColors.primaryBurgundy : AppColors.border),
              ),
              onSelected: (_) {
                ref.read(referralStatusFilterProvider.notifier).state = f['key']!;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReceivedList(
    BuildContext context,
    WidgetRef ref,
    List<ReferralItem> records,
    String statusFilter,
  ) {
    final filtered = statusFilter == 'all'
        ? records
        : records.where((r) => r.status.value.toLowerCase().contains(statusFilter)).toList();

    if (filtered.isEmpty) {
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
                Icons.mark_email_unread_outlined,
                size: 40,
                color: AppColors.primaryBurgundy,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Received Referrals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No business connect referrals have been received yet. Engage with your chapter network to receive verified leads.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildReferralCard(context, ref, item, isReceived: true);
      },
    );
  }

  Widget _buildGivenList(
    BuildContext context,
    WidgetRef ref,
    List<ReferralItem> records,
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
                color: AppColors.accentOrange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 40,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Given Referrals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have not passed any referrals to your chapter members yet. Support your fellow members by sharing a business opportunity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () async {
                final submitted = await AddReferralBottomSheet.show(context);
                if (submitted == true) {
                  ref.invalidate(referralDataProvider);
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Pass New Referral'),
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
        final item = records[index];
        return _buildReferralCard(context, ref, item, isReceived: false);
      },
    );
  }

  Widget _buildReferralCard(
    BuildContext context,
    WidgetRef ref,
    ReferralItem item, {
    required bool isReceived,
  }) {
    Color statusColor;
    Color statusBgColor;

    switch (item.status) {
      case ReferralLiveStatus.businessDone:
        statusColor = const Color(0xFF146C43);
        statusBgColor = const Color(0xFFD1E7DD);
        break;
      case ReferralLiveStatus.contacted:
        statusColor = const Color(0xFF0D6EFD);
        statusBgColor = const Color(0xFFE3F2FD);
        break;
      case ReferralLiveStatus.needSometime:
        statusColor = const Color(0xFFDC3545);
        statusBgColor = const Color(0xFFFDE2E2);
        break;
      case ReferralLiveStatus.cancelled:
        statusColor = const Color(0xFF842029);
        statusBgColor = const Color(0xFFF8D7DA);
        break;
      case ReferralLiveStatus.openForDiscussion:
        statusColor = const Color(0xFF856404);
        statusBgColor = const Color(0xFFFFF3CD);
        break;
    }

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
          // Header: Temperature, Status, Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.temperature == ReferralTemperature.hot
                          ? AppColors.errorLight
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.temperature.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.temperature == ReferralTemperature.hot
                            ? AppColors.error
                            : AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.date.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      item.date,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Referral Name & Contact
          Text(
            item.referralName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (item.contactNumber.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  item.contactNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // Flow Member Details: From -> To
          Row(
            children: [
              Expanded(
                child: _buildMemberInfoColumn(
                  label: 'From',
                  name: item.fromMemberName,
                  email: item.fromMemberEmail,
                  avatarUrl: item.fromMemberAvatar,
                ),
              ),
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
              Expanded(
                child: _buildMemberInfoColumn(
                  label: 'To',
                  name: item.toMemberName,
                  email: item.toMemberEmail,
                  avatarUrl: item.toMemberAvatar,
                ),
              ),
            ],
          ),

          if (item.description.isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Footer Action (Update Status for Received Referrals)
          if (isReceived) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final updated = await UpdateReferralStatusSheet.show(context, item);
                  if (updated == true) {
                    ref.invalidate(referralDataProvider);
                  }
                },
                icon: const Icon(Icons.edit_note, size: 16, color: AppColors.primaryBurgundy),
                label: const Text(
                  'Update Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ),
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
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';

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
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryBurgundy.withOpacity(0.1),
                shape: BoxShape.circle,
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
            ),
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
                      fontSize: 12,
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
}
