import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/visitor_model.dart';
import '../../../data/repositories/visitor_repository.dart';

final visitorsDataProvider = FutureProvider.autoDispose<VisitorsPageData>((ref) async {
  final repo = ref.watch(visitorRepositoryProvider);
  return await repo.getVisitorsData();
});

class VisitorsScreen extends ConsumerWidget {
  const VisitorsScreen({super.key});

  void _showAddVisitorDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
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
                      const Icon(Icons.person_add_alt_outlined, color: Colors.white),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Register Visitor',
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
                          const Text('Visitor Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Anand Kumar',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Enter visitor name' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Company / Business *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: companyCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. BuildTech Infra',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Enter company name' : null,
                          ),
                          const SizedBox(height: 14),
                          const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'e.g. 9888877777',
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'e.g. anand@buildtech.com',
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

                                      final payload = VisitorSubmissionPayload(
                                        visitorName: nameCtrl.text.trim(),
                                        company: companyCtrl.text.trim(),
                                        email: emailCtrl.text.trim(),
                                        phone: phoneCtrl.text.trim(),
                                        dateVisited: dateCtrl.text.trim(),
                                      );

                                      final repo = ref.read(visitorRepositoryProvider);
                                      final res = await repo.submitVisitor(payload);

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(res['message']?.toString() ?? 'Visitor registered!'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                        ref.invalidate(visitorsDataProvider);
                                      }
                                    },
                              child: isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Save Visitor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
    final vAsync = ref.watch(visitorsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Visitors Tracking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Visitor', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddVisitorDialog(context, ref),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBurgundy,
        onRefresh: () async {
          ref.invalidate(visitorsDataProvider);
          await ref.read(visitorsDataProvider.future);
        },
        child: vAsync.when(
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
                      child: const Icon(Icons.badge_outlined, color: AppColors.primaryBurgundy, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Visitors Tracked', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '${data.totalVisitors}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBurgundy),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (data.visitors.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'No Visitors Found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Track prospective members and guests attending WINCO Chapter meetings.',
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
                        label: const Text('Add Visitor Record'),
                        onPressed: () => _showAddVisitorDialog(context, ref),
                      ),
                    ],
                  ),
                )
              else
                ...data.visitors.map((v) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBurgundy.withOpacity(0.1),
                          child: Text(v.visitorName.isNotEmpty ? v.visitorName[0].toUpperCase() : 'V'),
                        ),
                        title: Text(v.visitorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${v.company} • ${v.visitedDate}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(v.status, style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy)),
          error: (error, _) => ErrorView(message: error.toString(), onRetry: () => ref.invalidate(visitorsDataProvider)),
        ),
      ),
    );
  }
}

