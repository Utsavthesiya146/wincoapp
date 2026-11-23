class BlogModel {
  final String id;
  final String title;
  final String category;
  final String excerpt;
  final String content;
  final String author;
  final DateTime publishedDate;
  final String? imageUrl;
  final int readTimeMinutes;

  const BlogModel({
    required this.id,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.content,
    required this.author,
    required this.publishedDate,
    this.imageUrl,
    this.readTimeMinutes = 4,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Infrastructure Insights',
      excerpt: json['excerpt'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'WINCO Editorial',
      publishedDate: json['published_date'] != null
          ? DateTime.tryParse(json['published_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['image_url'],
      readTimeMinutes: (json['read_time_minutes'] as num?)?.toInt() ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'excerpt': excerpt,
      'content': content,
      'author': author,
      'published_date': publishedDate.toIso8601String(),
      'image_url': imageUrl,
      'read_time_minutes': readTimeMinutes,
    };
  }
}

