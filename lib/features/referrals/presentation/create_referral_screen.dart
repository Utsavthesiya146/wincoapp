import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/referral_model.dart';
import '../../../data/repositories/referral_repository.dart';
import 'referral_screen.dart';
import 'widgets/add_referral_bottom_sheet.dart';

class CreateReferralScreen extends ConsumerStatefulWidget {
  final String? initialToMemberId;
  final String? initialToMemberName;

  const CreateReferralScreen({
    super.key,
    this.initialToMemberId,
    this.initialToMemberName,
  });

  @override
  ConsumerState<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends ConsumerState<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();

  String _memberForm = 'chapter';
  String? _selectedUserCode;
  String _temperature = 'Hot';
  String _status = 'Open for Discussion';

  final _businessController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedUserCode = widget.initialToMemberId;
  }

  @override
  void dispose() {
    _businessController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReferral() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUserCode == null || _selectedUserCode!.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a recipient WINCO member';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payload = ReferralSubmissionPayload(
        memberForm: _memberForm,
        toUser: _selectedUserCode!,
        business: _businessController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        temperature: _temperature,
        status: _status,
      );

      final repo = ref.read(referralRepositoryProvider);
      final result = await repo.submitReferral(payload);

      if (mounted) {
        if (result['status'] == 'success') {
          ref.invalidate(referralDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result['message']?.toString() ?? 'Referral Added Successfully & Email Sent',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        } else {
          setState(() {
            _isSubmitting = false;
            _errorMessage = result['message']?.toString() ?? 'Failed to send referral';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(referralMembersListProvider(_memberForm));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Pass Business Referral'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Member Source
              const Text(
                'Select Member From *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile(
                      label: 'My Chapter',
                      value: 'chapter',
                      isSelected: _memberForm == 'chapter',
                      onTap: () {
                        if (_memberForm != 'chapter') {
                          setState(() {
                            _memberForm = 'chapter';
                            _selectedUserCode = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildRadioTile(
                      label: 'Across All Chapters',
                      value: 'all',
                      isSelected: _memberForm == 'all',
                      onTap: () {
                        if (_memberForm != 'all') {
                          setState(() {
                            _memberForm = 'all';
                            _selectedUserCode = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Member Select
              const Text(
                'Send Connect To *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              membersAsync.when(
                data: (members) {
                  return DropdownButtonFormField<String>(
                    value: _selectedUserCode,
                    isExpanded: true,
                    decoration: _inputDecoration('Select a WINCO Member'),
                    hint: const Text('-- Select Member --'),
                    items: members.map((m) {
                      return DropdownMenuItem<String>(
                        value: m.userCode,
                        child: Text(m.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a member';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        _selectedUserCode = val;
                      });
                    },
                  );
                },
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBurgundy),
                      ),
                      SizedBox(width: 12),
                      Text('Loading members list...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Failed to load members: $err', style: const TextStyle(fontSize: 12, color: AppColors.error)),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Referral Name
              const Text(
                'Referral Name *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _businessController,
                decoration: _inputDecoration('e.g. Prestige Group Foundation Work'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter referral / business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Referral Contact
              const Text(
                'Referral Contact *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Phone number').copyWith(
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryBurgundy, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter referral contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 5. Temperature & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Temperature *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _temperature,
                          decoration: _inputDecoration('Temperature'),
                          items: const [
                            DropdownMenuItem(value: 'Hot', child: Text('🔥 Hot')),
                            DropdownMenuItem(value: 'Warm', child: Text('🌤 Warm')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _temperature = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: _inputDecoration('Status'),
                          items: const [
                            DropdownMenuItem(value: 'Open for Discussion', child: Text('Open for Discussion')),
                            DropdownMenuItem(value: 'Bussiness Done', child: Text('Business Done')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Details
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Scope of requirements, notes...'),
              ),
              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReferral,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Send Referral Now',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBurgundy.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBurgundy : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? AppColors.primaryBurgundy : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryBurgundy : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBurgundy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
