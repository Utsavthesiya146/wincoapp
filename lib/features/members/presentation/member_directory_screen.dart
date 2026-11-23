import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/prime_badge.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';

final memberQueryProvider = StateProvider<String>((ref) => '');
final memberCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredMembersProvider = FutureProvider<List<MemberModel>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  final query = ref.watch(memberQueryProvider);
  final category = ref.watch(memberCategoryProvider);

  return await repo.getMembers(
    query: query,
    category: category == 'All' ? null : category,
  );
});

final categoriesListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return await repo.getCategories();
});

class MemberDirectoryScreen extends ConsumerWidget {
  const MemberDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(filteredMembersProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final selectedCategory = ref.watch(memberCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Member Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Quick category filter bottom sheet
              _showFilterBottomSheet(context, ref);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CustomTextField(
              hint: 'Search by name, company, or category...',
              prefixIcon: Icons.search,
              onChanged: (val) {
                ref.read(memberQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Categories Horizontal Chips
          categoriesAsync.when(
            data: (categories) {
              return Container(
                color: AppColors.white,
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBurgundy,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.surfaceLight,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(memberCategoryProvider.notifier).state = cat;
                        }
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const Divider(height: 1),

          // Members List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryBurgundy,
              onRefresh: () async {
                ref.invalidate(filteredMembersProvider);
              },
              child: membersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.person_off_outlined,
                      title: 'No Members Found',
                      message: 'Try adjusting your search terms or industry filter.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberCard(context, member);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
                ),
                error: (error, _) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(filteredMembersProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MemberModel member) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/member-profile/${member.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with gold border and topCenter alignment
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF9B309), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.5),
                      child: (member.profileImageUrl != null &&
                              member.profileImageUrl!.isNotEmpty &&
                              !member.profileImageUrl!.contains('empty.png'))
                          ? Image.network(
                              member.profileImageUrl!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (_, __, ___) => _buildAvatarFallback(member),
                            )
                          : _buildAvatarFallback(member),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.fullName,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (member.isPrimeMember) const PrimeBadge(isCompact: true),
                          ],
                        ),
                        const SizedBox(height: 3),
                        if (member.businessName.isNotEmpty &&
                            member.businessName.toLowerCase() != member.businessCategory.toLowerCase()) ...[
                          Text(
                            member.businessName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBurgundy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          member.businessCategory.isNotEmpty ? member.businessCategory : 'Member',
                          style: TextStyle(
                            fontSize: (member.businessName.isNotEmpty &&
                                    member.businessName.toLowerCase() != member.businessCategory.toLowerCase())
                                ? 12
                                : 13,
                            fontWeight: (member.businessName.isNotEmpty &&
                                    member.businessName.toLowerCase() != member.businessCategory.toLowerCase())
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: (member.businessName.isNotEmpty &&
                                    member.businessName.toLowerCase() != member.businessCategory.toLowerCase())
                                ? AppColors.textSecondary
                                : AppColors.primaryBurgundy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        member.chapterName.isNotEmpty ? member.chapterName : member.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Quick Call Button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.primaryBurgundy),
                        onPressed: () => AppFormatters.launchPhoneNumber(member.phone),
                      ),
                      // Quick Email Button
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.email_outlined, size: 18, color: AppColors.primaryBurgundy),
                        onPressed: () => AppFormatters.launchEmailAddress(
                          member.email,
                          subject: 'WINCO Networking Inquiry',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(MemberModel member) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.burgundyGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          member.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Industry Category',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ref.watch(categoriesListProvider).when(
                      data: (cats) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cats.map((cat) {
                          final isSelected = ref.watch(memberCategoryProvider) == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.primaryBurgundy,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) {
                                ref.read(memberCategoryProvider.notifier).state = cat;
                                Navigator.pop(context);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

