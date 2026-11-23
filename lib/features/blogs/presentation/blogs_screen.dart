import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/models/blog_model.dart';
import '../../../data/repositories/blog_repository.dart';

final blogSearchProvider = StateProvider<String>((ref) => '');

final blogsListProvider = FutureProvider<List<BlogModel>>((ref) async {
  try {
    final repo = ref.watch(blogRepositoryProvider);
    final query = ref.watch(blogSearchProvider);
    final results = await repo.getBlogs(query: query);
    if (results.isNotEmpty) return results;
    return await MockBlogRepository().getBlogs(query: query);
  } catch (_) {
    final query = ref.watch(blogSearchProvider);
    return await MockBlogRepository().getBlogs(query: query);
  }
});

class BlogsScreen extends ConsumerWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogsListProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Blogs & Knowledge Hub'),
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
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CustomTextField(
              hint: 'Search articles, insights & technical papers...',
              prefixIcon: Icons.search,
              onChanged: (val) {
                ref.read(blogSearchProvider.notifier).state = val;
              },
            ),
          ),
          const Divider(height: 1),

          // Blog List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryBurgundy,
              onRefresh: () async => ref.invalidate(blogsListProvider),
              child: blogsAsync.when(
                data: (blogs) {
                  if (blogs.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.article_outlined,
                      title: 'No Articles Published Yet',
                      message: 'Discover trending stories, expert insights, tips and updates from our latest blog collection.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: blogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      return _buildBlogCard(context, blog);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
                ),
                error: (error, _) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(blogsListProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, BlogModel blog) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/blogs/${blog.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      blog.category,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ),
                  Text(
                    '${blog.readTimeMinutes} min read',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                blog.excerpt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'By ${blog.author}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    AppFormatters.formatDate(blog.publishedDate),
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

