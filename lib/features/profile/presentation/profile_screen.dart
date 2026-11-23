import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/prime_badge.dart';

import '../../../data/models/member_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to log out of WINCO Connect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
      ref.invalidate(currentUserProvider);
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Profile with Website',
            onPressed: () {
              ref.invalidate(currentUserProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentUserProvider);
          await ref.read(currentUserProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Header Red Banner Card (Matches Website .profile-banner)
              userAsync.when(
                data: (user) {
                  final member = user ?? MockAuthRepository.mockMember;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFF5B0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Circular Profile Photo with Fallback
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: (member.profileImageUrl != null &&
                                        member.profileImageUrl!.isNotEmpty)
                                    ? Image.network(
                                        member.profileImageUrl!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        errorBuilder: (_, __, ___) => _buildAvatarFallback(member),
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return _buildAvatarFallback(member);
                                        },
                                      )
                                    : _buildAvatarFallback(member),
                              ),
                            ),
                            const SizedBox(width: 16),
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (member.isPrimeMember) ...[
                                        const SizedBox(width: 6),
                                        const PrimeBadge(),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    member.businessName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFFD54F),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Badges Row
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Member',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Since ${member.since}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (member.about != null && member.about!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.work_outline, size: 16, color: Color(0xFFFFD54F)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    member.about!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // View Full Profile Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF8B0000),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.account_circle_outlined, size: 16),
                            label: const Text(
                              'Profile Details',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                            onPressed: () => context.push('/members/${member.id}'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // 3-Column Performance Stats Card (Matches Website .stats-box)
              userAsync.when(
                data: (user) {
                  final member = user ?? MockAuthRepository.mockMember;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${member.referralsGiven}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Referral Given',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: AppColors.border),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${member.referralsReceived}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Referral Received',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: AppColors.border),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${member.meetingsAttended}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Meetings Attended',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Personal & Business Details Live Card
              userAsync.when(
                data: (user) {
                  final member = user ?? MockAuthRepository.mockMember;
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.badge, size: 18, color: AppColors.primaryBurgundy),
                                SizedBox(width: 8),
                                Text(
                                  'Personal & Business Details',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LIVE SYNCED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 22),
                        _buildDetailRow(
                          icon: Icons.business,
                          label: 'Company Name',
                          value: member.businessName,
                        ),
                        if (member.designation != null && member.designation!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.work_outline,
                            label: 'Designation',
                            value: member.designation!,
                          ),
                        _buildDetailRow(
                          icon: Icons.category_outlined,
                          label: 'Category & Industry',
                          value: member.businessCategory,
                        ),
                        _buildDetailRow(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: member.email,
                        ),
                        _buildDetailRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone / WhatsApp',
                          value: member.phone,
                        ),
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: member.location,
                        ),
                        if (member.website != null && member.website!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.language,
                            label: 'Website',
                            value: member.website!,
                            isLink: true,
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            const SizedBox(height: 18),

            // Settings & Navigation Menu
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.workspace_premium,
                    title: 'WINCO Prime Club',
                    subtitle: 'Exclusive infrastructure consortium access',
                    iconColor: const Color(0xFFD4AF37),
                    onTap: () => context.push('/prime-club'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.hub,
                    title: 'Chapters & Conclaves',
                    subtitle: 'Meeting agendas, schedules & locations',
                    iconColor: AppColors.primaryBurgundy,
                    onTap: () => context.push('/chapters'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.card_membership,
                    title: 'Membership Status & Application',
                    subtitle: 'Review tier status and registration info',
                    iconColor: AppColors.accentOrange,
                    onTap: () => context.push('/membership-status'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.article_outlined,
                    title: 'WINCO Blogs & Knowledge Hub',
                    subtitle: 'Industry insights and technology papers',
                    iconColor: const Color(0xFF1565C0),
                    onTap: () => context.push('/blogs'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.support_agent,
                    title: 'Contact & Support',
                    subtitle: '${AppConstants.officialPhoneDisplay} • ${AppConstants.officialEmail}',
                    iconColor: const Color(0xFF2E7D32),
                    onTap: () => context.push('/contact'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.language,
                    title: 'Official WINCO Website',
                    subtitle: 'Open wincoconnect.com in browser',
                    iconColor: AppColors.textSecondary,
                    onTap: () => AppFormatters.launchExternalUrl(AppConstants.officialWebsite),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Environment & Architecture Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Backend Integration Status',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppConfig.current.isProduction
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppConfig.current.isProduction ? 'PRODUCTION' : 'MOCK / OFFLINE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppConfig.current.isProduction
                                ? const Color(0xFF2E7D32)
                                : AppColors.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'API Target: ${AppConfig.current.apiBaseUrl}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sign Out Button
            OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
              label: const Text('Sign Out of Account', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 18),
            const Text(
              'App Version ${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textTertiary),
    );
  }

  Widget _buildAvatarFallback(MemberModel member) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        gradient: AppColors.burgundyGradient,
        shape: BoxShape.circle,
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBurgundy),
          const SizedBox(width: 10),
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: isLink
                ? InkWell(
                    onTap: () => AppFormatters.launchExternalUrl(value),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0),
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

