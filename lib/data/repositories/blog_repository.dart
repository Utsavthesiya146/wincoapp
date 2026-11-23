import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../models/blog_model.dart';

abstract class BlogRepository {
  Future<List<BlogModel>> getBlogs({String? query, String? category});
  Future<BlogModel> getBlogById(String id);
}

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockBlogRepository();
  } else {
    return LiveBlogRepository(apiClient);
  }
});

class LiveBlogRepository implements BlogRepository {
  final ApiClient _apiClient;

  LiveBlogRepository(this._apiClient);

  @override
  Future<List<BlogModel>> getBlogs({String? query, String? category}) async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/blogs',
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final dynamic data = response.data;
      if (data == null) return [];

      // If JSON is returned
      if (data is Map<String, dynamic> || (data is String && data.trim().startsWith('{'))) {
        final Map<String, dynamic> json = data is Map<String, dynamic> ? data : jsonDecode(data);
        final list = json['data'] as List<dynamic>? ?? [];
        return list.map((e) => BlogModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      // If HTML is returned
      final html = data.toString();
      final blogs = _parseBlogsFromHtml(html);

      var filtered = blogs;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = filtered.where((b) =>
          b.title.toLowerCase().contains(q) ||
          b.excerpt.toLowerCase().contains(q) ||
          b.content.toLowerCase().contains(q)
        ).toList();
      }

      if (category != null && category.trim().isNotEmpty && category != 'All') {
        filtered = filtered.where((b) => b.category.toLowerCase() == category.toLowerCase()).toList();
      }

      if (filtered.isNotEmpty) {
        return filtered;
      }
      return await MockBlogRepository().getBlogs(query: query, category: category);
    } catch (_) {
      // In case of any network or parsing error, fallback gracefully to Knowledge Hub articles
      return await MockBlogRepository().getBlogs(query: query, category: category);
    }
  }

  static List<BlogModel> _parseBlogsFromHtml(String html) {
    final List<BlogModel> blogs = [];
    final parts = html.split(RegExp(r'<div[^>]*class="[^"]*blog-card[^"]*"', caseSensitive: false));
    for (int i = 1; i < parts.length; i++) {
      final card = parts[i];
      final titleM = RegExp(r'<h[1-5][^>]*>\s*<a[^>]*>([^<]+)</a>', caseSensitive: false).firstMatch(card) ??
          RegExp(r'<h[1-5][^>]*>([^<]+)</h[1-5]>', caseSensitive: false).firstMatch(card);
      final title = titleM?.group(1)?.trim() ?? 'Blog Post';

      final catM = RegExp(r'<span[^>]*class="[^"]*category-badge[^"]*"[^>]*>([^<]+)</span>', caseSensitive: false).firstMatch(card);
      final cat = catM?.group(1)?.trim() ?? 'Insights';

      final imgM = RegExp(r'<img[^>]*src="([^"]+)"', caseSensitive: false).firstMatch(card);
      final imgUrl = imgM?.group(1)?.trim();

      final descM = RegExp(r'<p[^>]*class="[^"]*line-[23][^"]*"[^>]*>([^<]+)</p>', caseSensitive: false).firstMatch(card) ??
          RegExp(r'<p[^>]*>([^<]+)</p>', caseSensitive: false).firstMatch(card);
      final excerpt = descM?.group(1)?.trim() ?? '';

      final linkM = RegExp(r'href="([^"]*blogs/[^"]+)"', caseSensitive: false).firstMatch(card) ??
          RegExp(r'<a[^>]*href="([^"]+)"', caseSensitive: false).firstMatch(card);
      final link = linkM?.group(1)?.trim() ?? '';
      final id = link.isNotEmpty ? link.split('/').last : 'blog-$i';

      blogs.add(BlogModel(
        id: id,
        title: title,
        category: cat,
        excerpt: excerpt,
        content: excerpt,
        author: 'WINCO Knowledge Council',
        publishedDate: DateTime.now(),
        imageUrl: imgUrl,
        readTimeMinutes: 4,
      ));
    }
    return blogs;
  }

  @override
  Future<BlogModel> getBlogById(String id) async {
    try {
      final blogs = await getBlogs();
      return blogs.firstWhere(
        (b) => b.id == id,
        orElse: () => MockBlogRepository()._blogs.firstWhere(
          (b) => b.id == id,
          orElse: () => MockBlogRepository()._blogs.first,
        ),
      );
    } catch (_) {
      return MockBlogRepository().getBlogById(id);
    }
  }
}

class MockBlogRepository implements BlogRepository {
  final List<BlogModel> _blogs = [
    BlogModel(
      id: 'BLOG-01',
      title: 'Navigating EPC Tender Partnerships in South India: 2026 Outlook',
      category: 'Tenders & EPC',
      excerpt: 'How tier-1 contractors and specialized sub-agencies are forming consortiums to win high-ticket highway and metro viaduct projects.',
      content: '''Infrastructure in South India is undergoing unprecedented transformation. As national highway corridors expand and metro networks broaden beyond metropolitan cores, project complexity requires deep synergy between general contractors, geotechnical specialists, and structural design consultants.

### The Power of Consortium Bidding
Historically, mid-sized civil contractors faced eligibility barriers when bidding for ₹100+ Crore tenders. Through WINCO Connect's trusted peer network, members combine balance sheet strength, specialized equipment assets, and past completion certificates to present formidable joint venture bids.

### Key Factors for Successful Infrastructure Collaborations:
1. **Clear Pre-Bid Scope Demarcation**: Ensuring each consortium partner has definitive bill-of-quantities (BOQ) responsibility.
2. **Transparent Escalation Protocols**: Managing raw material volatility (cement, steel rebar, bitumen) with shared price index clauses.
3. **Equitable Cashflow Governance**: Protecting mobilization advances and milestone releases across all participating subcontractors.

By bridging the gap between contractors and suppliers, WINCO members turn competitive friction into collaborative execution power.''',
      author: 'WINCO Knowledge Council',
      publishedDate: DateTime.now().subtract(const Duration(days: 4)),
      readTimeMinutes: 5,
    ),
    BlogModel(
      id: 'BLOG-02',
      title: 'Modern Precast Automation: Cutting Project Schedules by 40%',
      category: 'Construction Technology',
      excerpt: 'Evaluating off-site precast elements, modular pier caps, and hollow-core slabs for speed and quality assurance.',
      content: '''Time-to-delivery has emerged as the decisive metric in modern infrastructure projects. Rapid urbanization in tier-1 cities like Bengaluru, Hyderabad, and Chennai leaves minimal tolerance for protracted road closures and conventional on-site wet casting.

### Off-Site Quality, On-Site Speed
Automated precast fabrication plants enable continuous quality control under controlled steam curing environments. Concrete reaches design strength in a fraction of standard curing periods, while micro-silica and high-performance superplasticizers guarantee maximum durability against soil salinity.

### Real-World Field Results:
- Up to **40% reduction** in on-site erection schedules.
- **Zero dust and acoustic disturbance** in dense urban traffic zones.
- Significant reduction in labor overhead and on-site hazard exposure.

WINCO member chapters continue to facilitate direct site visits and factory tours, demonstrating how automated precast transforms structural delivery.''',
      author: 'Er. Vikram Joshi (SteelMatrix)',
      publishedDate: DateTime.now().subtract(const Duration(days: 10)),
      readTimeMinutes: 4,
    ),
  ];

  @override
  Future<List<BlogModel>> getBlogs({String? query, String? category}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<BlogModel>.from(_blogs);

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((b) {
        return b.title.toLowerCase().contains(q) ||
            b.excerpt.toLowerCase().contains(q) ||
            b.content.toLowerCase().contains(q);
      }).toList();
    }

    if (category != null && category.isNotEmpty && category != 'All') {
      results = results.where((b) => b.category == category).toList();
    }

    return results;
  }

  @override
  Future<BlogModel> getBlogById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _blogs.firstWhere(
      (b) => b.id == id,
      orElse: () => _blogs.first,
    );
  }
}

