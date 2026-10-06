class TokenizationAssignmentModel {
  const TokenizationAssignmentModel({
    required this.id,
    required this.assignmentReference,
    required this.proposalId,
    required this.status,
    required this.priority,
    this.proposalReference,
    this.proposalStatus,
    this.proposedTokenName,
    this.proposedTokenCode,
    this.assetId,
    this.assetCode,
    this.assetName,
    this.assignedTo,
    this.assignedFirstName,
    this.assignedLastName,
    this.assignedEmail,
    this.assignerFirstName,
    this.assignerLastName,
    this.notes,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
  });

  final int id;
  final String assignmentReference;

  final int proposalId;

  final String status;
  final String priority;

  final String? proposalReference;
  final String? proposalStatus;
  final String? proposedTokenName;
  final String? proposedTokenCode;

  final int? assetId;
  final String? assetCode;
  final String? assetName;

  final int? assignedTo;

  final String? assignedFirstName;
  final String? assignedLastName;
  final String? assignedEmail;

  final String? assignerFirstName;
  final String? assignerLastName;

  final String? notes;

  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  factory TokenizationAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TokenizationAssignmentModel(
      id: _toInt(json['id']),
      assignmentReference: json['assignmentReference']?.toString() ?? '',
      proposalId: _toInt(json['proposalId']),
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'normal',
      proposalReference: json['proposalReference']?.toString(),
      proposalStatus: json['proposalStatus']?.toString(),
      proposedTokenName: json['proposedTokenName']?.toString(),
      proposedTokenCode: json['proposedTokenCode']?.toString(),
      assetId: json['assetId'] == null ? null : _toInt(json['assetId']),
      assetCode: json['assetCode']?.toString(),
      assetName: json['assetName']?.toString(),
      assignedTo: json['assignedTo'] == null
          ? null
          : _toInt(json['assignedTo']),
      assignedFirstName: json['assignedFirstName']?.toString(),
      assignedLastName: json['assignedLastName']?.toString(),
      assignedEmail: json['assignedEmail']?.toString(),
      assignerFirstName: json['assignerFirstName']?.toString(),
      assignerLastName: json['assignerLastName']?.toString(),
      notes: json['notes']?.toString(),
      assignedAt: _toDate(json['assignedAt']),
      startedAt: _toDate(json['startedAt']),
      completedAt: _toDate(json['completedAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class TokenizationOfficerModel {
  const TokenizationOfficerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.roleName,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? roleName;

  String get fullName => '$firstName $lastName'.trim();

  factory TokenizationOfficerModel.fromJson(Map<String, dynamic> json) {
    return TokenizationOfficerModel(
      id: _toInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      roleName: json['roleName']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
