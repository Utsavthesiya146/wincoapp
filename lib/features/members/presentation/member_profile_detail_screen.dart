import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/prime_badge.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';

final memberDetailProvider = FutureProvider.family<MemberModel, String>((ref, id) async {
  final repo = ref.watch(memberRepositoryProvider);
  return await repo.getMemberById(id);
});

class MemberProfileDetailScreen extends ConsumerWidget {
  final String memberId;

  const MemberProfileDetailScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailProvider(memberId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Member Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member profile link copied to clipboard.')),
              );
            },
          ),
        ],
      ),
      body: memberAsync.when(
        data: (member) => _buildProfileContent(context, member),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
        ),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(memberDetailProvider(memberId)),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, MemberModel member) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF9B309), width: 2.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.5),
                    child: (member.profileImageUrl != null &&
                            member.profileImageUrl!.isNotEmpty &&
                            !member.profileImageUrl!.contains('empty.png'))
                        ? Image.network(
                            member.profileImageUrl!,
                            width: 95,
                            height: 95,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => _buildDetailAvatarFallback(member),
                          )
                        : _buildDetailAvatarFallback(member),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (member.isPrimeMember) ...[
                      const SizedBox(width: 8),
                      const PrimeBadge(),
                    ],
                  ],
                ),
                if (member.chapterName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    member.chapterName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  member.businessName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBurgundy,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (member.businessCategory.isNotEmpty &&
                    member.businessCategory.toLowerCase() != member.businessName.toLowerCase()) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.businessCategory,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 14),
                // Action Buttons (Call, Email, Referral)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleAction(
                      icon: Icons.phone,
                      label: 'Call',
                      onTap: () => AppFormatters.launchPhoneNumber(member.phone),
                    ),
                    const SizedBox(width: 20),
                    _buildCircleAction(
                      icon: Icons.email,
                      label: 'Email',
                      onTap: () => AppFormatters.launchEmailAddress(
                        member.email,
                        subject: 'WINCO Connect Referral Inquiry',
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildCircleAction(
                      icon: Icons.handshake,
                      label: 'Refer',
                      color: AppColors.accentOrange,
                      onTap: () => context.push(
                        '/create-referral?toMemberId=${member.id}&toMemberName=${Uri.encodeComponent(member.fullName)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Networking Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${member.referralsGiven}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Referrals Given',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.border),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppFormatters.formatCompactINR(member.businessDone),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Business Done',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Business Details
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                if (member.businessName.isNotEmpty) _buildInfoRow('Business', member.businessName),
                _buildInfoRow('Category', member.businessCategory),
                _buildInfoRow('Chapter', member.chapterName),
                if (member.since.isNotEmpty && member.since != '2024') _buildInfoRow('Established', member.since),
                _buildInfoRow('Location', member.location),
                if (member.gstNumber != null && member.gstNumber!.isNotEmpty) _buildInfoRow('GSTIN', member.gstNumber!),
                if (member.phone.isNotEmpty) _buildInfoRow('Phone', member.phone),
                if (member.email.isNotEmpty) _buildInfoRow('Email', member.email),
                if (member.website != null && member.website!.isNotEmpty) _buildInfoRow('Website', member.website!),
              ],
            ),
          ),

          if (member.about != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Business',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    member.about!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Pass Referral Primary CTA
          PrimaryButton(
            text: 'Pass Referral to ${member.firstName}',
            icon: Icons.handshake,
            onPressed: () {
              context.push(
                '/create-referral?toMemberId=${member.id}&toMemberName=${Uri.encodeComponent(member.fullName)}',
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailAvatarFallback(MemberModel member) {
    return Container(
      width: 95,
      height: 95,
      decoration: const BoxDecoration(
        gradient: AppColors.burgundyGradient,
      ),
      child: Center(
        child: Text(
          member.initials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primaryBurgundy,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

