import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/repositories/membership_repository.dart';

class MembershipRegistrationScreen extends ConsumerStatefulWidget {
  const MembershipRegistrationScreen({super.key});

  @override
  ConsumerState<MembershipRegistrationScreen> createState() => _MembershipRegistrationScreenState();
}

class _MembershipRegistrationScreenState extends ConsumerState<MembershipRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sinceController = TextEditingController();
  final _locationController = TextEditingController();
  final _gstController = TextEditingController();

  bool _isLoading = false;

  final List<String> _industryCategories = [
    'Civil Contracting & EPC',
    'Structural Engineering & Design',
    'Precast Concrete & PEB',
    'Building Materials & Ready-Mix',
    'Geotechnical Engineering & Piling',
    'Heavy Machinery & Cranes',
    'Electrical & Solar EPC',
    'Architecture & Urban Planning',
    'Project Management & PMC',
    'Roads & Highway Construction',
    'HVAC & MEP Services',
    'Steel & Rebar Fabrication',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _categoryController.dispose();
    _sinceController.dispose();
    _locationController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _selectSinceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBurgundy,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _sinceController.text = picked.year.toString();
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final req = MembershipApplicationRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessCategory: _categoryController.text.trim(),
        since: _sinceController.text.trim(),
        location: _locationController.text.trim(),
        gstNumber: _gstController.text.trim().isNotEmpty ? _gstController.text.trim() : null,
      );

      final success = await ref.read(membershipRepositoryProvider).submitApplication(req);

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('Application Received'),
                ],
              ),
              content: Text(
                'Thank you, ${_firstNameController.text}! Your WINCO membership application has been submitted to the chapter committee. You will be contacted shortly for chapter induction verification.',
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    context.go('/login');
                  },
                  child: const Text('Return to Login'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Membership Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.burgundyGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join WINCO Connect',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'World Infra Networking Community membership is designed exclusively for infrastructure leaders, contractors, and specialized consultants.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      hint: 'First name',
                      prefixIcon: Icons.person_outline,
                      validator: (val) => AppValidators.validateRequired(val, 'First Name'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Last Name *',
                      hint: 'Last name',
                      prefixIcon: Icons.person_outline,
                      validator: (val) => AppValidators.validateRequired(val, 'Last Name'),
                    ),
                  ),
                ],
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

              const SizedBox(height: 22),

              // Business Information Section
              const Text(
                'Business & Enterprise Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _businessNameController,
                label: 'Business Name *',
                hint: 'Registered company or firm name',
                prefixIcon: Icons.apartment_outlined,
                validator: (val) => AppValidators.validateRequired(val, 'Business Name'),
              ),
              const SizedBox(height: 14),

              // Business Category Dropdown
              const Text(
                'Business Category *',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select your primary category'),
                    value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                    items: _industryCategories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _categoryController.text = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _sinceController,
                      label: 'Since (Year) *',
                      hint: 'YYYY',
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _selectSinceDate,
                      validator: (val) => AppValidators.validateRequired(val, 'Since Year'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _locationController,
                      label: 'Location (City) *',
                      hint: 'e.g. Bengaluru',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (val) => AppValidators.validateRequired(val, 'Location'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _gstController,
                label: 'GST Number (Optional)',
                hint: '15-character GSTIN (optional)',
                prefixIcon: Icons.receipt_long_outlined,
                validator: (val) => AppValidators.validateGstOptional(val),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Submit Membership Application',
                icon: Icons.send,
                onPressed: _submitRegistration,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

