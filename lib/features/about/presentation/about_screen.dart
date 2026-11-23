import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/primary_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('About WINCO Connect'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  AppLogo(size: 80),
                  SizedBox(height: 16),
                  Text(
                    'WORLD INFRA NETWORKING COMMUNITY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.secondaryBurgundy,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'WINCO is a premier business networking forum exclusively created for the infrastructure, construction, civil engineering, EPC, and building material sectors. We unite industry decision-makers to build connections, create high-ticket opportunities, and grow together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Live Verified Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatBadge('77+', 'Active Members', Icons.people_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBadge('6+', 'Active Chapters', Icons.location_city_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatBadge('₹7.77 Cr+', 'Business Done', Icons.trending_up),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBadge('₹10.09 L+', 'Avg Referral', Icons.handshake_outlined),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mission & Vision
            _buildInfoCard(
              title: 'Our Mission',
              icon: Icons.track_changes,
              content:
                  'To build a trusted networking ecosystem where professionals can connect, collaborate, and create opportunities that strengthen the infrastructure sector.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Our Vision',
              icon: Icons.visibility_outlined,
              content:
                  'To become a global hub for infrastructure professionals, expanding beyond borders and building a sustainable, innovation-driven business community.',
            ),

            const SizedBox(height: 28),

            // Section: Why Choose Us
            const Text(
              'Why Choose Us?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBurgundy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Because here, networking turns into real business growth.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            _buildPillarTile(
              icon: Icons.hub_outlined,
              title: 'Strong Industry Network',
              description: 'Connect with top professionals across multiple infra sectors.',
            ),
            _buildPillarTile(
              icon: Icons.business_center_outlined,
              title: 'Collaboration Opportunities',
              description: 'Partner on diverse and high-value infrastructure projects.',
            ),
            _buildPillarTile(
              icon: Icons.visibility_outlined,
              title: 'Business Visibility',
              description: 'Showcase your services and generate quality b2b leads.',
            ),
            _buildPillarTile(
              icon: Icons.recommend_outlined,
              title: 'Trusted Referrals',
              description: 'Grow faster with high-reputation peer recommendations.',
            ),
            _buildPillarTile(
              icon: Icons.school_outlined,
              title: 'Skill & Knowledge Growth',
              description: 'Stay ahead with continuous technical and managerial learning.',
            ),
            _buildPillarTile(
              icon: Icons.support_agent_outlined,
              title: 'Professional Support System',
              description: 'Guidance and support at every stage of business expansion.',
            ),
            _buildPillarTile(
              icon: Icons.lightbulb_outline,
              title: 'Innovation & Exposure',
              description: 'Access new construction tech ideas, trends, and strategies.',
            ),
            _buildPillarTile(
              icon: Icons.public_outlined,
              title: 'National & Global Reach',
              description: 'Expand your infrastructure business beyond regional boundaries.',
            ),

            const SizedBox(height: 24),

            // Prime Club Callout Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBurgundy, AppColors.secondaryBurgundy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBurgundy.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, size: 14, color: AppColors.white),
                            SizedBox(width: 4),
                            Text(
                              'PRIME ACCESS',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlock Premium Growth Opportunities',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'WINCO membership is designed to maximize your business potential with priority project access, fortnightly leadership meetups, and dedicated performance recognition.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFF0E0E0),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    text: 'JOIN THE COMMUNITY',
                    icon: Icons.arrow_forward,
                    backgroundColor: AppColors.accentOrange,
                    textColor: AppColors.white,
                    height: 48,
                    onPressed: () {
                      context.push('/register');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Contact Secretariat Button
            OutlinedButton.icon(
              icon: const Icon(Icons.support_agent, color: AppColors.primaryBurgundy),
              label: const Text(
                'Contact Secretariat & Support',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBurgundy,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primaryBurgundy, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.push('/contact');
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.accentOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primaryBurgundy),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryBurgundy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

