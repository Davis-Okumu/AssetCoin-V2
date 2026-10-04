
class Announcement {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime? publishedAt;
  final DateTime? expiresAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.publishedAt,
    this.expiresAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}