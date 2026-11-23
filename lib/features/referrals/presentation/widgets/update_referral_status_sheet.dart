import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/referral_model.dart';
import '../../../../data/repositories/referral_repository.dart';

class UpdateReferralStatusSheet extends ConsumerStatefulWidget {
  final ReferralItem referral;

  const UpdateReferralStatusSheet({super.key, required this.referral});

  static Future<bool?> show(BuildContext context, ReferralItem referral) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateReferralStatusSheet(referral: referral),
    );
  }

  @override
  ConsumerState<UpdateReferralStatusSheet> createState() => _UpdateReferralStatusSheetState();
}

class _UpdateReferralStatusSheetState extends ConsumerState<UpdateReferralStatusSheet> {
  late String _selectedStatus;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<Map<String, String>> _statusOptions = const [
    {'value': 'open for discussion', 'label': 'Open for Discussion', 'icon': '💬'},
    {'value': 'contacted', 'label': 'Contacted', 'icon': '📞'},
    {'value': 'not converted', 'label': 'Need Sometime', 'icon': '⏳'},
    {'value': 'business done', 'label': 'Business Done', 'icon': '🤝'},
    {'value': 'cancelled', 'label': 'Cancelled', 'icon': '❌'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.referral.status.value;
    // Normalize status if not in list
    if (!_statusOptions.any((opt) => opt['value'] == _selectedStatus.toLowerCase())) {
      _selectedStatus = 'open for discussion';
    }
  }

  Future<void> _updateStatus() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payload = ReferralStatusUpdatePayload(
        referralCode: widget.referral.id,
        status: _selectedStatus,
      );

      final repo = ref.read(referralRepositoryProvider);
      final result = await repo.updateReferralStatus(payload);

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
                      result['message']?.toString() ?? 'Status Updated Successfully',
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
            _errorMessage = result['message']?.toString() ?? 'Failed to update status';
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    Icons.edit_note_rounded,
                    color: AppColors.primaryBurgundy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Referral Status',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.referral.id} • ${widget.referral.referralName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],

            const Text(
              'Select Current Pipeline Status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            ..._statusOptions.map((opt) {
              final isSelected = _selectedStatus.toLowerCase() == opt['value']!.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected ? AppColors.primaryBurgundy.withOpacity(0.06) : AppColors.lightBackground,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBurgundy : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Text(opt['icon']!, style: const TextStyle(fontSize: 18)),
                    title: Text(
                      opt['label']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primaryBurgundy : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primaryBurgundy, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedStatus = opt['value']!;
                      });
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _updateStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Confirm Status Update',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
