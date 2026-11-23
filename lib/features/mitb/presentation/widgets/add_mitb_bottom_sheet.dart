import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/mitb_model.dart';
import '../../../../data/repositories/mitb_repository.dart';

final mitbMembersListProvider = FutureProvider.family<List<MitbMemberOption>, String>((ref, type) async {
  final repo = ref.watch(mitbRepositoryProvider);
  return await repo.getMembers(type: type);
});

class AddMitbBottomSheet extends ConsumerStatefulWidget {
  const AddMitbBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMitbBottomSheet(),
    );
  }

  @override
  ConsumerState<AddMitbBottomSheet> createState() => _AddMitbBottomSheetState();
}

class _AddMitbBottomSheetState extends ConsumerState<AddMitbBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'My Chapter Member';
  String? _selectedUserCode;
  String _businessType = 'New';
  DateTime _selectedDate = DateTime.now();

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _memberQueryType {
    if (_selectedCategory == 'Across Chapter Member') {
      return 'all';
    }
    return 'chapter';
  }

  bool get _requiresMemberSelection {
    return _selectedCategory == 'My Chapter Member' || _selectedCategory == 'Across Chapter Member';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitSlip() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_requiresMemberSelection && (_selectedUserCode == null || _selectedUserCode!.isEmpty)) {
      setState(() {
        _errorMessage = 'Please select the member who gave you this business';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final payload = MitbSubmissionPayload(
        category: _selectedCategory,
        toUser: _selectedUserCode ?? '',
        amount: _amountController.text.trim().replaceAll(RegExp(r'[^\d.]'), ''),
        businessType: _businessType,
        createdAt: dateFormatted,
        description: _descriptionController.text.trim(),
      );

      final repo = ref.read(mitbRepositoryProvider);
      final result = await repo.submitMitb(payload);

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
                      result['message']?.toString() ?? 'Business Done Added Successfully',
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
            _errorMessage = result['message']?.toString() ?? 'Failed to submit business done slip';
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
    final membersAsync = _requiresMemberSelection ? ref.watch(mitbMembersListProvider(_memberQueryType)) : null;

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
                // Header Bar & Handle
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBurgundy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: AppColors.primaryBurgundy,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Business Done 💸',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enter details of closed business received',
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

                // 1. Who gave you this business?
                const Text(
                  'Who gave you this business? 🤝 *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration('Select business source'),
                  items: const [
                    DropdownMenuItem(value: 'My Chapter Member', child: Text('My Chapter Member')),
                    DropdownMenuItem(value: 'Across Chapter Member', child: Text('Across Chapter Member')),
                    DropdownMenuItem(value: 'Visitor', child: Text('Visitor')),
                    DropdownMenuItem(value: 'New', child: Text('New')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                        _selectedUserCode = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // 2. Select Member Who Gave Business
                if (_requiresMemberSelection) ...[
                  const Text(
                    'Select Member Who Gave Business 👤 *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  membersAsync!.when(
                    data: (members) {
                      return DropdownButtonFormField<String>(
                        value: _selectedUserCode,
                        isExpanded: true,
                        decoration: _inputDecoration('Select a member'),
                        hint: const Text('-- Select Member --'),
                        items: members.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.userCode,
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (val) {
                          if (_requiresMemberSelection && (val == null || val.isEmpty)) {
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
                ],

                // 3. Amount (INR)
                const Text(
                  'Business Closed Amount (INR) 💰 *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Enter amount in Rupees').copyWith(
                    prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryBurgundy, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter closed business amount';
                    }
                    final numVal = double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), ''));
                    if (numVal == null || numVal <= 0) {
                      return 'Enter a valid positive amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 4. Business Type & Date Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Type 📈 *',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _businessType,
                            decoration: _inputDecoration('Type'),
                            items: const [
                              DropdownMenuItem(value: 'New', child: Text('New Business')),
                              DropdownMenuItem(value: 'Repeat', child: Text('Repeat Business')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _businessType = val);
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
                            'Date of Business 📅 *',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(_selectedDate),
                                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryBurgundy),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. Description of Business
                const Text(
                  'Description of Business ✨',
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
                  decoration: _inputDecoration('Enter brief description of services or products closed...'),
                ),
                const SizedBox(height: 22),

                // Submit & Cancel buttons
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
                        onPressed: _isSubmitting ? null : _submitSlip,
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
                                'Submit Business Done',
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
