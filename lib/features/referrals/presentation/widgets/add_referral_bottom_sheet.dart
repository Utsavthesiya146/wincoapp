import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/mitb_model.dart';
import '../../../../data/models/referral_model.dart';
import '../../../../data/repositories/referral_repository.dart';

final referralMembersListProvider = FutureProvider.family<List<MitbMemberOption>, String>((ref, type) async {
  final repo = ref.watch(referralRepositoryProvider);
  return await repo.getMembers(type: type);
});

class AddReferralBottomSheet extends ConsumerStatefulWidget {
  final String? preselectedUserCode;

  const AddReferralBottomSheet({super.key, this.preselectedUserCode});

  static Future<bool?> show(BuildContext context, {String? preselectedUserCode}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReferralBottomSheet(preselectedUserCode: preselectedUserCode),
    );
  }

  @override
  ConsumerState<AddReferralBottomSheet> createState() => _AddReferralBottomSheetState();
}

class _AddReferralBottomSheetState extends ConsumerState<AddReferralBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String _memberForm = 'chapter'; // 'chapter' or 'all'
  String? _selectedUserCode;
  String _temperature = 'Hot';
  String _status = 'Open for Discussion';

  late final TextEditingController _businessController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedUserCode = widget.preselectedUserCode;
    _businessController = TextEditingController();
    _contactController = TextEditingController();
    _descriptionController = TextEditingController();
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
          Navigator.of(context).pop(true);
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final membersAsync = ref.watch(referralMembersListProvider(_memberForm));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.accentOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Referral Opportunity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pass a verified business connect to a member',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                  const SizedBox(height: 14),
                ],

                // 1. Select Member From (Radio Toggle)
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
                      child: _buildSourceRadioTile(
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
                      child: _buildSourceRadioTile(
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
                const SizedBox(height: 14),

                // 2. Send Connect To (Member Dropdown)
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
                      decoration: _inputDecoration('Search and select member'),
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
                      color: AppColors.lightBackground,
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
                        Text(
                          'Loading members list...',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  error: (err, _) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Failed to load members: $err',
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Referral Name (Business/Lead Name)
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
                const SizedBox(height: 14),

                // 4. Referral Contact (Phone)
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
                  decoration: _inputDecoration('Contact phone number').copyWith(
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryBurgundy, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter referral contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 5. Temperature & Status Row
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
                const SizedBox(height: 14),

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
                  decoration: _inputDecoration('Enter scope of requirements, background notes, etc.'),
                ),
                const SizedBox(height: 22),

                // Submit Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReferral,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBurgundy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Send Referral',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceRadioTile({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBurgundy.withOpacity(0.08) : AppColors.lightBackground,
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

