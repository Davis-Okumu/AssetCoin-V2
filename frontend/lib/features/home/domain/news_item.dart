
class NewsItem {
  final int id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final String category;
  final DateTime? publishedAt;

  const NewsItem({
    required this.id,
    required this.title,
    this.summary,
    this.imageUrl,
    required this.category,
    this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      summary: json['summary'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
    );
  }
}