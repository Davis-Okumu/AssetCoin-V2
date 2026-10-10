class AdminNotificationModel {
  const AdminNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.status,
    required this.createdAt,
    this.staffId,
    this.referenceType,
    this.referenceId,
    this.readAt,
  });

  final int id;
  final int? staffId;
  final String type;
  final String title;
  final String message;
  final String status;
  final String? referenceType;
  final int? referenceId;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isNew => status == 'new';
  bool get isRead => status == 'read';
  bool get isArchived => status == 'archived';

  // Global notifications are shared records. Until the backend supports
  // per-staff read receipts, the UI must not mutate their shared status.
  bool get isGlobal => staffId == null;

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      return DateTime.tryParse(value.toString());
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return AdminNotificationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      staffId: parseNullableInt(json['staffId']),
      type: (json['type'] ?? 'system').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? 'new').toString(),
      referenceType: json['referenceType']?.toString(),
      referenceId: parseNullableInt(json['referenceId']),
      readAt: parseDate(json['readAt']),
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class AdminNotificationOverview {
  const AdminNotificationOverview({
    this.total = 0,
    this.newCount = 0,
    this.readCount = 0,
    this.archivedCount = 0,
  });

  final int total;
  final int newCount;
  final int readCount;
  final int archivedCount;

  factory AdminNotificationOverview.fromJson(Map<String, dynamic> json) {
    int readCount(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

    return AdminNotificationOverview(
      total: readCount(json['total']),
      newCount: readCount(json['newCount'] ?? json['new']),
      readCount: readCount(json['readCount'] ?? json['read']),
      archivedCount: readCount(json['archivedCount'] ?? json['archived']),
    );
  }
}
