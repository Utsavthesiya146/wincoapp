import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Connect With Industry Professionals',
      'subtitle': 'Network exclusively with vetted infrastructure contractors, structural engineers, architects, and top decision-makers.',
      'icon': Icons.people_alt_outlined,
      'badge': 'TRUSTED NETWORK',
    },
    {
      'title': 'Discover Business Opportunities',
      'subtitle': 'Gain direct access to active infrastructure tenders, material procurement demands, and private commercial inquiries.',
      'icon': Icons.trending_up,
      'badge': 'GROWTH PIPELINE',
    },
    {
      'title': 'Collaborate on Infrastructure Projects',
      'subtitle': 'Form powerful consortiums and joint venture partnerships to bid for and execute mega EPC, highway, and metro packages.',
      'icon': Icons.handshake_outlined,
      'badge': 'CONSORTIUM ALLIANCES',
    },
    {
      'title': 'Grow Through Business Referrals',
      'subtitle': 'Track transparent closed business slips and exchange high-ticket peer referrals across regional chapters in South India.',
      'icon': Icons.currency_rupee,
      'badge': '₹7.77+ CR GENERATED',
    },
  ];

  Future<void> _completeOnboarding() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.setOnboardingCompleted();
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Illustration Container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBurgundy.withOpacity(0.06),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBurgundy.withOpacity(0.12),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBurgundy,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                page['icon'] as IconData,
                                size: 48,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            page['badge'] as String,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentOrange,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Title
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Subtitle
                        Text(
                          page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots & Bottom Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryBurgundy
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: isLastPage ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                    icon: isLastPage ? Icons.arrow_forward : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

