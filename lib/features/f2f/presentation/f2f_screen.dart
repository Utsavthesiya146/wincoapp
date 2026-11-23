import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/f2f_model.dart';
import '../../../data/repositories/f2f_repository.dart';
import 'widgets/add_f2f_bottom_sheet.dart';
import 'widgets/update_f2f_status_sheet.dart';

final f2fDataProvider = FutureProvider.autoDispose<F2fPageData>((ref) async {
  final repo = ref.watch(f2fRepositoryProvider);
  return await repo.getF2fData();
});

final f2fFilterProvider = StateProvider.autoDispose<String>((ref) => 'all');
final f2fSearchProvider = StateProvider.autoDispose<String>((ref) => '');

class F2fScreen extends ConsumerWidget {
  const F2fScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f2fAsync = ref.watch(f2fDataProvider);
    final activeFilter = ref.watch(f2fFilterProvider);
    final searchQuery = ref.watch(f2fSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          "1-to-1 Meetings (121's)",
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
            tooltip: 'Record 121',
            onPressed: () async {
              final pageData = f2fAsync.valueOrNull;
              final submitted = await AddF2fBottomSheet.show(
                context,
                members: pageData?.members ?? [],
              );
              if (submitted == true) {
                ref.invalidate(f2fDataProvider);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.people_alt_rounded),
        label: const Text(
          'Record 121 🤝',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final pageData = f2fAsync.valueOrNull;
          final submitted = await AddF2fBottomSheet.show(
            context,
            members: pageData?.members ?? [],
          );
          if (submitted == true) {
            ref.invalidate(f2fDataProvider);
          }
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(f2fDataProvider);
          await ref.read(f2fDataProvider.future);
        },
        child: f2fAsync.when(
          data: (data) => _buildContent(context, ref, data, activeFilter, searchQuery),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
          ),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(f2fDataProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    F2fPageData data,
    String activeFilter,
    String searchQuery,
  ) {
    // Filter meetings
    final filteredMeetings = data.meetings.where((m) {
      if (activeFilter != 'all') {
        if (activeFilter == 'scheduled' && m.status != F2fStatus.scheduled && m.status != F2fStatus.rescheduled) {
          return false;
        }
        if (activeFilter == 'completed' && m.status != F2fStatus.completed) {
          return false;
        }
        if (activeFilter == 'cancelled' && m.status != F2fStatus.cancelled) {
          return false;
        }
      }

      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesTo = m.toMemberName.toLowerCase().contains(query);
        final matchesFrom = m.fromMemberName.toLowerCase().contains(query);
        final matchesLoc = m.location.toLowerCase().contains(query);
        final matchesSummary = m.summary.toLowerCase().contains(query);
        if (!matchesTo && !matchesFrom && !matchesLoc && !matchesSummary) {
          return false;
        }
      }

      return true;
    }).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        // 1. Performance Summary Header
        _buildSummaryHeader(data.summary),
        const SizedBox(height: 16),

        // 2. Search Box
        _buildSearchBar(ref, searchQuery),
        const SizedBox(height: 12),

        // 3. Status Filter Chips
        _buildFilterChips(ref, activeFilter, data.summary),
        const SizedBox(height: 16),

        // 4. Meetings Records List
        if (filteredMeetings.isEmpty)
          _buildEmptyState(context, ref, data.members)
        else
          ...filteredMeetings.map((m) => _buildMeetingCard(context, ref, m)),
      ],
    );
  }

  Widget _buildSummaryHeader(F2fSummary summary) {
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
                    Icon(Icons.diversity_3_outlined, color: AppColors.primaryBurgundy, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "My 121's Networking Pipeline",
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
            'Official 1-to-1 business meetings conducted with WINCO members',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: "Total 121's",
                  value: '${summary.totalMeetings}',
                  valueColor: AppColors.primaryBurgundy,
                  icon: Icons.groups_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Scheduled',
                  value: '${summary.scheduledCount}',
                  valueColor: const Color(0xFF0D6EFD),
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Completed',
                  value: '${summary.completedCount}',
                  valueColor: AppColors.success,
                  icon: Icons.check_circle_outline,
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: valueColor),
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

  Widget _buildSearchBar(WidgetRef ref, String query) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: TextEditingController(text: query)..selection = TextSelection.collapsed(offset: query.length),
        onChanged: (val) => ref.read(f2fSearchProvider.notifier).state = val,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by member, location or topic...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                  onPressed: () => ref.read(f2fSearchProvider.notifier).state = '',
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, String activeFilter, F2fSummary summary) {
    final filters = [
      {'key': 'all', 'label': 'All (${summary.totalMeetings})'},
      {'key': 'scheduled', 'label': 'Scheduled (${summary.scheduledCount})'},
      {'key': 'completed', 'label': 'Completed (${summary.completedCount})'},
      {'key': 'cancelled', 'label': 'Cancelled (${summary.cancelledCount})'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBurgundy : AppColors.border,
                ),
              ),
              onSelected: (val) {
                if (val) {
                  ref.read(f2fFilterProvider.notifier).state = f['key']!;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, WidgetRef ref, F2fMeetingItem meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Date & Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightBackground.withOpacity(0.6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primaryBurgundy),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meeting.meetingDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: meeting.status.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(meeting.status.icon, size: 12, color: meeting.status.color),
                      const SizedBox(width: 4),
                      Text(
                        meeting.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: meeting.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Body: Participants & Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Members Flow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // From Member
                    Expanded(
                      child: _buildParticipantCell(
                        role: 'From',
                        name: meeting.fromMemberName,
                        email: meeting.fromMemberEmail,
                        avatarUrl: meeting.fromMemberAvatar,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                    // To Member
                    Expanded(
                      child: _buildParticipantCell(
                        role: 'With',
                        name: meeting.toMemberName,
                        email: meeting.toMemberEmail,
                        avatarUrl: meeting.toMemberAvatar,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Location Row
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.accentOrange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meeting.location.isNotEmpty ? meeting.location : 'Location Not Specified',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Summary / Topics Discussed
                if (meeting.summary.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      meeting.summary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Created: ${meeting.createdDate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBurgundy,
                        side: const BorderSide(color: AppColors.primaryBurgundy),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Update Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final updated = await UpdateF2fStatusSheet.show(context, meeting);
                        if (updated == true) {
                          ref.invalidate(f2fDataProvider);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCell({
    required String role,
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'W';

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryBurgundy.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBurgundy,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, List<F2fMemberOption> members) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
              Icons.people_outline_rounded,
              size: 40,
              color: AppColors.primaryBurgundy,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No 1-to-1 Meetings Recorded',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Schedule or log face-to-face meetings with chapter members to strengthen connections and unlock referrals.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Record 121 Meeting', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              final submitted = await AddF2fBottomSheet.show(context, members: members);
              if (submitted == true) {
                ref.invalidate(f2fDataProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}
