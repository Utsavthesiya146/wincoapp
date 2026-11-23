import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.02),

                  // Brand Crest / Logo Card
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBurgundy.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.accentOrange.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: AppLogo(size: 110, isHero: true),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Organization Name
                  const Center(
                    child: Text(
                      'WORLD INFRA NETWORKING COMMUNITY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: AppColors.secondaryBurgundy,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App Title
                  const Center(
                    child: Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentOrange.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.handshake_outlined,
                            size: 16,
                            color: AppColors.accentOrange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Feature Cards / Brief Overview
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Build Connections. Create Opportunities. Grow Together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'A premier networking forum designed exclusively for infrastructure and construction professionals across India.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Button 1: JOIN NOW
                  PrimaryButton(
                    text: 'JOIN NOW',
                    icon: Icons.person_add_alt_1,
                    backgroundColor: AppColors.primaryBurgundy,
                    textColor: AppColors.white,
                    height: 54,
                    onPressed: () {
                      context.push('/register');
                    },
                  ),

                  const SizedBox(height: 16),

                  // Button 2: MEMBER LOGIN
                  PrimaryButton(
                    text: 'MEMBER LOGIN',
                    icon: Icons.login,
                    isOutlined: true,
                    backgroundColor: AppColors.primaryBurgundy,
                    textColor: AppColors.primaryBurgundy,
                    height: 54,
                    onPressed: () {
                      context.push('/login');
                    },
                  ),

                  const SizedBox(height: 28),

                  // Discover Platform Modules
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'EXPLORE WINCO PLATFORM',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickNav(
                        context,
                        icon: Icons.info_outline,
                        label: 'About',
                        onTap: () => context.push('/about'),
                      ),
                      _buildQuickNav(
                        context,
                        icon: Icons.article_outlined,
                        label: 'Blogs',
                        onTap: () => context.push('/blogs'),
                      ),
                      _buildQuickNav(
                        context,
                        icon: Icons.location_city_outlined,
                        label: 'Chapters',
                        onTap: () => context.push('/chapters'),
                      ),
                      _buildQuickNav(
                        context,
                        icon: Icons.workspace_premium_outlined,
                        label: 'Prime',
                        onTap: () => context.push('/prime-club'),
                      ),
                      _buildQuickNav(
                        context,
                        icon: Icons.support_agent_outlined,
                        label: 'Contact',
                        onTap: () => context.push('/contact'),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Footer
                  const Center(
                    child: Text(
                      'Official Portal: wincoconnect.com',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickNav(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryBurgundy),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

