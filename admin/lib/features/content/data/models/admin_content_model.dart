/// Represents a single content record managed by the AssetCoin
/// Admin Dashboard.
///
/// Supported types:
/// - announcements
/// - news
/// - publications
class AdminContentModel {
  const AdminContentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    this.summary,
    this.content,
    this.category,
    this.imageUrl,
    this.documentUrl,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.authorId,
    this.authorName,
    this.publishedBy,
  });

  final int id;
  final String type;
  final String title;
  final String status;

  final String? summary;
  final String? content;
  final String? category;
  final String? imageUrl;
  final String? documentUrl;

  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  /// Existing customer-user author ID, where applicable.
  final int? authorId;

  /// Display name of the content author, if returned by the API.
  final String? authorName;

  /// Staff or user ID that published the content, if returned.
  final int? publishedBy;

  // ============================================================
  // JSON PARSING
  // ============================================================

  factory AdminContentModel.fromJson(
    Map<String, dynamic> json, {
    required String type,
  }) {
    return AdminContentModel(
      id: _asInt(json['id']),
      type: type,
      title: _asString(json['title']) ?? '',
      status: _asString(json['status']) ?? 'draft',
      summary: _asString(json['summary']),
      content: _asString(json['content']),
      category: _asString(json['category']),
      imageUrl: _asString(json['imageUrl'] ?? json['image_url']),
      documentUrl: _asString(json['documentUrl'] ?? json['document_url']),
      publishedAt: _asDateTime(json['publishedAt'] ?? json['published_at']),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _asDateTime(json['updatedAt'] ?? json['updated_at']),
      expiresAt: _asDateTime(json['expiresAt'] ?? json['expires_at']),
      authorId: _asNullableInt(
        json['authorId'] ??
            json['authorStaffId'] ??
            json['author_id'] ??
            json['author_staff_id'],
      ),
      authorName: _asString(
        json['authorName'] ?? json['author_name'] ?? json['author'],
      ),
      publishedBy: _asNullableInt(
        json['publishedByStaffId'] ??
            json['publishedBy'] ??
            json['published_by_staff_id'] ??
            json['published_by'],
      ),
    );
  }

  // ============================================================
  // JSON SERIALIZATION
  // ============================================================

  /// Serializes editable content fields.
  ///
  /// IDs, timestamps, and audit fields are intentionally omitted;
  /// the backend should manage those fields.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  bool get isDraft => status == 'draft';

  bool get isPublished => status == 'published';

  bool get isArchived => status == 'archived';

  bool get isAnnouncement => type == 'announcements';

  bool get isNews => type == 'news';

  bool get isPublication => type == 'publications';

  String get displayType {
    switch (type) {
      case 'announcements':
        return 'Announcement';
      case 'news':
        return 'News';
      case 'publications':
        return 'Publication';
      default:
        return _capitalize(type);
    }
  }

  String get displayStatus => _capitalize(status);

  /// Human-readable category name for display in tables and forms.
  ///
  /// Returns an em dash when the record has no category.
  String get categoryDisplayName {
    final value = category?.trim();

    if (value == null || value.isEmpty) {
      return '—';
    }

    return value.split('_').map(_capitalize).join(' ');
  }

  /// Human-readable category name with an uncategorized fallback.
  String get displayCategory {
    final value = category?.trim();

    if (value == null || value.isEmpty) {
      return 'Uncategorized';
    }

    return value.split('_').map(_capitalize).join(' ');
  }

  // ============================================================
  // PARSING HELPERS
  // ============================================================

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;

    return '${value[0].toUpperCase()}'
        '${value.substring(1).replaceAll('_', ' ')}';
  }
}

// ================================================================
// CONTENT OVERVIEW
// ================================================================

/// Overview statistics for a single content type.
class AdminContentTypeStats {
  const AdminContentTypeStats({
    this.total = 0,
    this.drafts = 0,
    this.published = 0,
    this.archived = 0,
  });

  final int total;
  final int drafts;
  final int published;
  final int archived;

  factory AdminContentTypeStats.fromJson(Map<String, dynamic> json) {
    return AdminContentTypeStats(
      total: _asInt(json['total']),
      drafts: _asInt(json['drafts']),
      published: _asInt(json['published']),
      archived: _asInt(json['archived']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

/// Aggregated overview statistics for all content types.
class AdminContentOverview {
  const AdminContentOverview({
    this.announcements = const AdminContentTypeStats(),
    this.news = const AdminContentTypeStats(),
    this.publications = const AdminContentTypeStats(),
  });

  final AdminContentTypeStats announcements;
  final AdminContentTypeStats news;
  final AdminContentTypeStats publications;

  factory AdminContentOverview.fromJson(Map<String, dynamic> json) {
    return AdminContentOverview(
      announcements: _parseStats(json['announcements']),
      news: _parseStats(json['news']),
      publications: _parseStats(json['publications']),
    );
  }

  int get total => announcements.total + news.total + publications.total;

  int get drafts => announcements.drafts + news.drafts + publications.drafts;

  int get published =>
      announcements.published + news.published + publications.published;

  int get archived =>
      announcements.archived + news.archived + publications.archived;

  static AdminContentTypeStats _parseStats(dynamic value) {
    if (value is Map) {
      return AdminContentTypeStats.fromJson(Map<String, dynamic>.from(value));
    }

    return const AdminContentTypeStats();
  }
}
