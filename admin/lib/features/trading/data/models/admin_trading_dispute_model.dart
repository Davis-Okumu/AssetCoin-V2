class AdminTradingDisputeModel {
  const AdminTradingDisputeModel({
    required this.id,
    required this.disputeReference,
    this.transactionId,
    this.orderId,
    this.listingId,
    required this.raisedBy,
    this.againstUserId,
    required this.disputeType,
    required this.priority,
    required this.status,
    required this.reason,
    this.description,
    this.assignedTo,
    this.resolutionNotes,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
    this.raisedByFirstName,
    this.raisedByLastName,
    this.raisedByEmail,
    this.raisedByPhone,
    this.againstUserFirstName,
    this.againstUserLastName,
    this.againstUserEmail,
    this.assignedToFirstName,
    this.assignedToLastName,
  });

  final int id;
  final String disputeReference;

  final int? transactionId;
  final int? orderId;
  final int? listingId;

  final int raisedBy;
  final int? againstUserId;

  final String disputeType;
  final String priority;
  final String status;
  final String reason;

  final String? description;

  final int? assignedTo;

  final String? resolutionNotes;
  final int? resolvedBy;

  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? raisedByFirstName;
  final String? raisedByLastName;
  final String? raisedByEmail;
  final String? raisedByPhone;

  final String? againstUserFirstName;
  final String? againstUserLastName;
  final String? againstUserEmail;

  final String? assignedToFirstName;
  final String? assignedToLastName;

  factory AdminTradingDisputeModel.fromJson(Map<String, dynamic> json) {
    return AdminTradingDisputeModel(
      id: _asInt(json['id']),
      disputeReference: _asString(json['disputeReference']),
      transactionId: _asNullableInt(json['transactionId']),
      orderId: _asNullableInt(json['orderId']),
      listingId: _asNullableInt(json['listingId']),
      raisedBy: _asInt(json['raisedBy']),
      againstUserId: _asNullableInt(json['againstUserId']),
      disputeType: _asString(json['disputeType']),
      priority: _asString(json['priority'], fallback: 'normal'),
      status: _asString(json['status'], fallback: 'open'),
      reason: _asString(json['reason']),
      description: _asNullableString(json['description']),
      assignedTo: _asNullableInt(json['assignedTo']),
      resolutionNotes: _asNullableString(json['resolutionNotes']),
      resolvedBy: _asNullableInt(json['resolvedBy']),
      resolvedAt: _asDateTime(json['resolvedAt']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      raisedByFirstName: _asNullableString(json['raisedByFirstName']),
      raisedByLastName: _asNullableString(json['raisedByLastName']),
      raisedByEmail: _asNullableString(json['raisedByEmail']),
      raisedByPhone: _asNullableString(json['raisedByPhone']),
      againstUserFirstName: _asNullableString(json['againstUserFirstName']),
      againstUserLastName: _asNullableString(json['againstUserLastName']),
      againstUserEmail: _asNullableString(json['againstUserEmail']),
      assignedToFirstName: _asNullableString(json['assignedToFirstName']),
      assignedToLastName: _asNullableString(json['assignedToLastName']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disputeReference': disputeReference,
      'transactionId': transactionId,
      'orderId': orderId,
      'listingId': listingId,
      'raisedBy': raisedBy,
      'againstUserId': againstUserId,
      'disputeType': disputeType,
      'priority': priority,
      'status': status,
      'reason': reason,
      'description': description,
      'assignedTo': assignedTo,
      'resolutionNotes': resolutionNotes,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'raisedByFirstName': raisedByFirstName,
      'raisedByLastName': raisedByLastName,
      'raisedByEmail': raisedByEmail,
      'raisedByPhone': raisedByPhone,
      'againstUserFirstName': againstUserFirstName,
      'againstUserLastName': againstUserLastName,
      'againstUserEmail': againstUserEmail,
      'assignedToFirstName': assignedToFirstName,
      'assignedToLastName': assignedToLastName,
    };
  }

  String get raisedByName {
    final parts = <String>[
      if (raisedByFirstName != null && raisedByFirstName!.trim().isNotEmpty)
        raisedByFirstName!.trim(),
      if (raisedByLastName != null && raisedByLastName!.trim().isNotEmpty)
        raisedByLastName!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Unknown customer';
    }

    return parts.join(' ');
  }

  String get againstUserName {
    final parts = <String>[
      if (againstUserFirstName != null &&
          againstUserFirstName!.trim().isNotEmpty)
        againstUserFirstName!.trim(),
      if (againstUserLastName != null && againstUserLastName!.trim().isNotEmpty)
        againstUserLastName!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Not specified';
    }

    return parts.join(' ');
  }

  String get assignedToName {
    final parts = <String>[
      if (assignedToFirstName != null && assignedToFirstName!.trim().isNotEmpty)
        assignedToFirstName!.trim(),
      if (assignedToLastName != null && assignedToLastName!.trim().isNotEmpty)
        assignedToLastName!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Unassigned';
    }

    return parts.join(' ');
  }

  String get disputeTypeLabel {
    switch (disputeType.toLowerCase()) {
      case 'trade':
        return 'Trade';
      case 'order':
        return 'Order';
      case 'listing':
        return 'Listing';
      case 'payment':
        return 'Payment';
      case 'asset':
        return 'Asset';
      default:
        return _titleCase(disputeType);
    }
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return _titleCase(priority);
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'under_review':
        return 'Under Review';
      case 'awaiting_information':
        return 'Awaiting Information';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      case 'closed':
        return 'Closed';
      default:
        return _titleCase(status);
    }
  }

  bool get isOpen => status.toLowerCase() == 'open';

  bool get isUnderReview => status.toLowerCase() == 'under_review';

  bool get isAwaitingInformation =>
      status.toLowerCase() == 'awaiting_information';

  bool get isResolved => status.toLowerCase() == 'resolved';

  bool get isRejected => status.toLowerCase() == 'rejected';

  bool get isClosed => status.toLowerCase() == 'closed';

  bool get isFinalized => isResolved || isRejected || isClosed;

  bool get isAssigned => assignedTo != null;

  bool get isCritical => priority.toLowerCase() == 'critical';

  bool get isHighPriority =>
      priority.toLowerCase() == 'high' || priority.toLowerCase() == 'critical';

  bool get hasTransaction => transactionId != null;

  bool get hasOrder => orderId != null;

  bool get hasListing => listingId != null;

  bool get hasResolution =>
      resolutionNotes != null && resolutionNotes!.trim().isNotEmpty;

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    return result.isEmpty ? fallback : result;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static String _titleCase(String value) {
    final normalized = value.replaceAll('_', ' ').trim();

    if (normalized.isEmpty) {
      return value;
    }

    return normalized
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
