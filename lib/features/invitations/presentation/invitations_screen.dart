import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/repositories/invitation_repository.dart';

final invitationsDataProvider = FutureProvider.autoDispose<InvitationsPageData>((ref) async {
  final repo = ref.watch(invitationRepositoryProvider);
  return await repo.getInvitationsData();
});

class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  void _showAddInvitationDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            margin: EdgeInsets.only(bottom: bottomInset),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBurgundy,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, color: Colors.white),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Invite Business Guest',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Guest Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Rajesh Sharma',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Enter guest name' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Guest Email *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'e.g. rajesh@infra.com',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Guest Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'e.g. 9876543210',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: companyCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Apex Steel Ltd',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Invitation Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: messageCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Cordially invite you to our business conclave...',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBurgundy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (isSubmitting) return;
                                      if (!formKey.currentState!.validate()) return;
                                      setModalState(() => isSubmitting = true);

                                      final payload = InvitationSubmissionPayload(
                                        guestName: nameCtrl.text.trim(),
                                        guestEmail: emailCtrl.text.trim(),
                                        guestPhone: phoneCtrl.text.trim(),
                                        guestCompany: companyCtrl.text.trim(),
                                        message: messageCtrl.text.trim(),
                                      );

                                      final repo = ref.read(invitationRepositoryProvider);
                                      final res = await repo.submitInvitation(payload);

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']?.toString() ?? 'Invitation sent!'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                        ref.invalidate(invitationsDataProvider);
                                      }
                                    },
                              child: isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Send Invitation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invAsync = ref.watch(invitationsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Guest Invitations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBurgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.mail_outline_rounded),
        label: const Text('Invite Guest', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddInvitationDialog(context, ref),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(invitationsDataProvider);
          await ref.read(invitationsDataProvider.future);
        },
        child: invAsync.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBurgundy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_outline, color: AppColors.primaryBurgundy, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Invitations Sent', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '${data.totalInvitations}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBurgundy),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (data.invitations.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_unread_outlined, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'No Invitations Found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Invite external business owners, partners, and contractors to attend upcoming chapter meetings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBurgundy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Send First Invitation'),
                        onPressed: () => _showAddInvitationDialog(context, ref),
                      ),
                    ],
                  ),
                )
              else
                ...data.invitations.map((inv) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBurgundy.withOpacity(0.1),
                          child: Text(inv.guestName.isNotEmpty ? inv.guestName[0].toUpperCase() : 'G'),
                        ),
                        title: Text(inv.guestName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${inv.company} • ${inv.email}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(inv.status, style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy)),
          error: (error, _) => ErrorView(message: error.toString(), onRetry: () => ref.invalidate(invitationsDataProvider)),
        ),
      ),
    );
  }
}

