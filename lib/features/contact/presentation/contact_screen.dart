import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/repositories/contact_repository.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(contactRepositoryProvider).sendContactMessage(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
          );

      if (success && mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('Inquiry Sent'),
                ],
              ),
              content: const Text(
                'Thank you for contacting WINCO Connect. Our support and member secretariat will get back to you promptly.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _nameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                    _subjectController.clear();
                    _messageController.clear();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Contact Support & Inquiries'),
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verified Contacts Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get in Touch with Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connect with us for guidance, membership inquiries, or chapter sponsorship.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  _buildContactActionTile(
                    icon: Icons.phone,
                    title: 'Call Support',
                    value: AppConstants.officialPhoneDisplay,
                    actionLabel: 'Call Now',
                    onTap: () => AppFormatters.launchPhoneNumber(AppConstants.officialPhoneDisplay),
                  ),
                  const Divider(height: 18),
                  _buildContactActionTile(
                    icon: Icons.email,
                    title: 'Email Address',
                    value: AppConstants.officialEmail,
                    actionLabel: 'Send Mail',
                    onTap: () => AppFormatters.launchEmailAddress(
                      AppConstants.officialEmail,
                      subject: 'WINCO Mobile Inquiry',
                    ),
                  ),
                  const Divider(height: 18),
                  _buildContactActionTile(
                    icon: Icons.language,
                    title: 'Official Website',
                    value: AppConstants.officialWebsite,
                    actionLabel: 'Visit',
                    onTap: () => AppFormatters.launchExternalUrl(AppConstants.officialWebsite),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Inquiries Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Send Us a Direct Message',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name *',
                      hint: 'Your name',
                      prefixIcon: Icons.person_outline,
                      validator: (val) => AppValidators.validateRequired(val, 'Name'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address *',
                      hint: 'name@company.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => AppValidators.validateEmail(val),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      hint: '10-digit mobile number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) => AppValidators.validatePhone(val),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _subjectController,
                      label: 'Subject *',
                      hint: 'e.g. Chapter Induction Query',
                      prefixIcon: Icons.subject,
                      validator: (val) => AppValidators.validateRequired(val, 'Subject'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _messageController,
                      label: 'Message *',
                      hint: 'Write your inquiry or requirement here...',
                      prefixIcon: Icons.message_outlined,
                      maxLines: 4,
                      validator: (val) => AppValidators.validateRequired(val, 'Message'),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      text: 'Send Message',
                      icon: Icons.send,
                      onPressed: _sendMessage,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactActionTile({
    required IconData icon,
    required String title,
    required String value,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryBurgundy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryBurgundy,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

