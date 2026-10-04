class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final String? referenceType;
  final int? referenceId;
  final String status;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    required this.status,
    this.readAt,
    required this.createdAt,
  });

  bool get isNew => status == 'new';

  bool get isViewed => status == 'viewed';

  factory AppNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppNotification(
      id: int.parse(json['id'].toString()),
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] == null
          ? null
          : int.parse(json['referenceId'].toString()),
      status: json['status'] as String,
      readAt: json['readAt'] == null
          ? null
          : DateTime.tryParse(json['readAt'].toString()),
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
    );
  }
}