import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class JoinCommunityRegistrationScreen extends StatefulWidget {
  const JoinCommunityRegistrationScreen({super.key});

  @override
  State<JoinCommunityRegistrationScreen> createState() =>
      _JoinCommunityRegistrationScreenState();
}

class _JoinCommunityRegistrationScreenState
    extends State<JoinCommunityRegistrationScreen> {
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

  DateTime? _selectedSinceDate;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _suggestedCategories = [
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
    'Interior & Commercial Infrastructure',
    'Water, Sewage & Pipeline Works',
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

  Future<void> _pickSinceDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedSinceDate ?? DateTime(now.year - 3, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'SELECT ESTABLISHMENT DATE (SINCE)',
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
        _selectedSinceDate = picked;
        // User-facing display: dd-mm-yyyy
        _sinceController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSinceDate == null && _sinceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the establishment date (Since).')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Format since date for server (YYYY-MM-DD or user text)
    final serverSince = _selectedSinceDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedSinceDate!)
        : _sinceController.text.trim();

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'X-Requested-With': 'XMLHttpRequest',
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          },
        ),
      );

      final payload = {
        'name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'business': _businessNameController.text.trim(),
        'category': _categoryController.text.trim(),
        'since': serverSince,
        'location': _locationController.text.trim(),
        'gst': _gstController.text.trim(),
      };

      final response = await dio.post(
        'https://wincoconnect.com/home/AddLead',
        data: payload,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );

      String message = 'Application submitted successfully!';
      bool isSuccess = false;

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.data.toString());
          if (decoded is Map) {
            message = decoded['message']?.toString() ?? message;
            isSuccess = decoded['status'] == 'success';
          } else {
            isSuccess = true;
          }
        } catch (_) {
          isSuccess = true;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (isSuccess) {
          _showSuccessDialog(message);
        } else {
          setState(() {
            _errorMessage = message;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Submission error: Please check your internet connection or try again.';
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF2E7D32),
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Registration Submitted!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    context.pop(); // return to home
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Join the Community',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Card Container matching Website Modal
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Modal Header Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: const BoxDecoration(
                            gradient: AppColors.burgundyGradient,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Join the Community',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Connect. Grow. Succeed.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Body
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Heading
                                const Text(
                                  'Get in Touch With Us',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBurgundy,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Description
                                const Text(
                                  'Be a part of Winco Connect and experience a new way of networking where every connection adds value.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Error Banner
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                ],

                                // 1. First Name*
                                CustomTextField(
                                  controller: _firstNameController,
                                  hint: 'First Name*',
                                  prefixIcon: Icons.person_outline,
                                  validator: (val) =>
                                      AppValidators.validateRequired(val, 'First Name'),
                                ),
                                const SizedBox(height: 14),

                                // 2. Last Name*
                                CustomTextField(
                                  controller: _lastNameController,
                                  hint: 'Last Name*',
                                  prefixIcon: Icons.person_outline,
                                  validator: (val) =>
                                      AppValidators.validateRequired(val, 'Last Name'),
                                ),
                                const SizedBox(height: 14),

                                // 3. Email Address*
                                CustomTextField(
                                  controller: _emailController,
                                  hint: 'Email Address*',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) => AppValidators.validateEmail(val),
                                ),
                                const SizedBox(height: 14),

                                // 4. Phone Number*
                                CustomTextField(
                                  controller: _phoneController,
                                  hint: 'Phone Number*',
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (val) => AppValidators.validatePhone(val),
                                ),
                                const SizedBox(height: 14),

                                // 5. Business Name*
                                CustomTextField(
                                  controller: _businessNameController,
                                  hint: 'Business Name*',
                                  prefixIcon: Icons.apartment_outlined,
                                  validator: (val) =>
                                      AppValidators.validateRequired(val, 'Business Name'),
                                ),
                                const SizedBox(height: 14),

                                // 6. Business Category* (with quick dropdown option)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      controller: _categoryController,
                                      hint: 'Business Category*',
                                      prefixIcon: Icons.category_outlined,
                                      validator: (val) =>
                                          AppValidators.validateRequired(
                                              val, 'Business Category'),
                                      suffixIcon: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.textTertiary,
                                        ),
                                        tooltip: 'Select common category',
                                        onSelected: (cat) {
                                          setState(() => _categoryController.text = cat);
                                        },
                                        itemBuilder: (context) {
                                          return _suggestedCategories.map((c) {
                                            return PopupMenuItem<String>(
                                              value: c,
                                              child: Text(
                                                c,
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // 7. Since - Date Picker (dd-mm-yyyy)
                                CustomTextField(
                                  controller: _sinceController,
                                  hint: 'Since* (dd-mm-yyyy)',
                                  prefixIcon: Icons.calendar_month_outlined,
                                  readOnly: true,
                                  onTap: _pickSinceDate,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please select establishment date (Since)';
                                    }
                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.date_range,
                                      color: AppColors.primaryBurgundy,
                                      size: 20,
                                    ),
                                    onPressed: _pickSinceDate,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // 8. Location*
                                CustomTextField(
                                  controller: _locationController,
                                  hint: 'Location*',
                                  prefixIcon: Icons.location_on_outlined,
                                  validator: (val) =>
                                      AppValidators.validateRequired(val, 'Location'),
                                ),
                                const SizedBox(height: 14),

                                // 9. GST Number (Optional)
                                CustomTextField(
                                  controller: _gstController,
                                  hint: 'GST Number (Optional)',
                                  prefixIcon: Icons.receipt_long_outlined,
                                  validator: (val) =>
                                      AppValidators.validateGstOptional(val),
                                ),
                                const SizedBox(height: 24),

                                // SUBMIT Button
                                PrimaryButton(
                                  text: 'SUBMIT',
                                  icon: Icons.send_rounded,
                                  height: 52,
                                  isLoading: _isLoading,
                                  backgroundColor: AppColors.primaryBurgundy,
                                  onPressed: _submitRegistration,
                                ),

                                const SizedBox(height: 18),

                                // Web Portal Registration Alternative
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      context.push(
                                        '/webview?url=https://wincoconnect.com/&title=WINCO+Web+Portal',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.language,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    label: const Text(
                                      'Open in Official Web Portal (WebView)',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

