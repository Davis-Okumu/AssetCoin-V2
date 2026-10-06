import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/admin_kyc_api.dart';
import '../models/admin_kyc_application.dart';
import '../models/admin_kyc_review.dart';
import '../models/admin_kyc_stats.dart';
import '../../../../core/network/api_client_provider.dart';

final adminKycApiProvider = Provider<AdminKycApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AdminKycApi(apiClient);
});

final adminKycRepositoryProvider = Provider<AdminKycRepository>((ref) {
  final api = ref.watch(adminKycApiProvider);

  return AdminKycRepository(api);
});

/// Repository for the AssetCoin Admin Dashboard KYC workflow.
///
/// Responsibilities:
/// - Communicate with [AdminKycApi].
/// - Convert API responses into strongly typed models.
/// - Expose a clean interface to Riverpod controllers.
///
/// The repository does not contain UI logic.
class AdminKycRepository {
  AdminKycRepository(this._api);

  final AdminKycApi _api;

  // ============================================================
  // GET APPLICATIONS
  // ============================================================

  /// Fetches paginated KYC applications.
  Future<AdminKycApplicationList> getApplications({
    String? status,
    String? search,
    int? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getApplications(
      status: status,
      search: search,
      assignedTo: assignedTo,
      page: page,
      limit: limit,
    );

    final data = _extractData(response);

    final applicationsJson = data['applications'];

    final applications = <AdminKycApplication>[];

    if (applicationsJson is List) {
      for (final item in applicationsJson) {
        if (item is Map) {
          applications.add(
            AdminKycApplication.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final paginationJson = data['pagination'];

    final pagination = AdminKycPagination.fromJson(
      paginationJson is Map
          ? Map<String, dynamic>.from(paginationJson)
          : const <String, dynamic>{},
    );

    return AdminKycApplicationList(
      applications: applications,
      pagination: pagination,
    );
  }

  // ============================================================
  // GET STATISTICS
  // ============================================================

  /// Fetches KYC dashboard statistics.
  Future<AdminKycStats> getStats() async {
    final response = await _api.getStats();

    final data = _extractData(response);

    return AdminKycStats.fromJson(data);
  }

  // ============================================================
  // GET APPLICATION DETAILS
  // ============================================================

  /// Fetches complete KYC application details.
  ///
  /// Includes:
  /// - application
  /// - assignment
  /// - review history
  Future<AdminKycDetails> getApplication(int kycId) async {
    final response = await _api.getApplication(kycId);

    final data = _extractData(response);

    final applicationJson = data['application'];

    if (applicationJson is! Map) {
      throw const FormatException('Invalid KYC application response.');
    }

    final application = AdminKycApplication.fromJson(
      Map<String, dynamic>.from(applicationJson),
    );

    final assignmentJson = data['assignment'];

    AdminKycAssignment? assignment;

    if (assignmentJson is Map) {
      assignment = AdminKycAssignment.fromJson(
        Map<String, dynamic>.from(assignmentJson),
      );
    }

    final reviewHistoryJson = data['reviewHistory'];

    final reviewHistory = <AdminKycReview>[];

    if (reviewHistoryJson is List) {
      for (final item in reviewHistoryJson) {
        if (item is Map) {
          reviewHistory.add(
            AdminKycReview.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return AdminKycDetails(
      application: application,
      assignment: assignment,
      reviewHistory: reviewHistory,
    );
  }

  // ============================================================
  // ASSIGN APPLICATION
  // ============================================================

  /// Assigns a KYC application to an admin staff member.
  Future<AdminKycAssignmentResult> assignApplication({
    required int kycId,
    required int assignedTo,
    String? priority,
    String? notes,
  }) async {
    final response = await _api.assignApplication(
      kycId: kycId,
      assignedTo: assignedTo,
      priority: priority,
      notes: notes,
    );

    final data = _extractData(response);

    return AdminKycAssignmentResult.fromJson(data);
  }

  // ============================================================
  // START REVIEW
  // ============================================================

  /// Starts the KYC review process.
  Future<AdminKycStatusChangeResult> startReview(int kycId) async {
    final response = await _api.startReview(kycId);

    final data = _extractData(response);

    return AdminKycStatusChangeResult.fromJson(data);
  }

  // ============================================================
  // REQUEST INFORMATION
  // ============================================================

  /// Requests additional information from the customer.
  Future<AdminKycInformationRequestResult> requestInformation({
    required int kycId,
    required String comments,
  }) async {
    final response = await _api.requestInformation(
      kycId: kycId,
      comments: comments,
    );

    final data = _extractData(response);

    return AdminKycInformationRequestResult.fromJson(data);
  }

  // ============================================================
  // APPROVE APPLICATION
  // ============================================================

  /// Approves a KYC application.
  Future<AdminKycStatusChangeResult> approveApplication(int kycId) async {
    final response = await _api.approveApplication(kycId);

    final data = _extractData(response);

    return AdminKycStatusChangeResult.fromJson(data);
  }

  // ============================================================
  // REJECT APPLICATION
  // ============================================================

  /// Rejects a KYC application.
  Future<AdminKycRejectionResult> rejectApplication({
    required int kycId,
    required String rejectionReason,
  }) async {
    final response = await _api.rejectApplication(
      kycId: kycId,
      rejectionReason: rejectionReason,
    );

    final data = _extractData(response);

    return AdminKycRejectionResult.fromJson(data);
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  /// Extracts the API `data` object.
  ///
  /// Your controllers return responses in the form:
  ///
  /// {
  ///   success: true,
  ///   data: {...}
  /// }
  ///
  /// The ApiClient already decodes the JSON, so this method
  /// simply normalizes that response.
  Map<String, dynamic> _extractData(dynamic response) {
    if (response is! Map) {
      throw const FormatException('Invalid API response.');
    }

    final responseMap = Map<String, dynamic>.from(response);

    final data = responseMap['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    // Allows the repository to continue working if an endpoint
    // returns its payload directly rather than inside `data`.
    return responseMap;
  }
}

// ================================================================
// APPLICATION LIST
// ================================================================

class AdminKycApplicationList {
  const AdminKycApplicationList({
    required this.applications,
    required this.pagination,
  });

  final List<AdminKycApplication> applications;
  final AdminKycPagination pagination;
}

// ================================================================
// PAGINATION
// ================================================================

class AdminKycPagination {
  const AdminKycPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory AdminKycPagination.fromJson(Map<String, dynamic> json) {
    return AdminKycPagination(
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 20),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['totalPages']),
    );
  }
}

// ================================================================
// KYC DETAILS
// ================================================================

class AdminKycDetails {
  const AdminKycDetails({
    required this.application,
    required this.assignment,
    required this.reviewHistory,
  });

  final AdminKycApplication application;
  final AdminKycAssignment? assignment;
  final List<AdminKycReview> reviewHistory;
}

// ================================================================
// ASSIGNMENT
// ================================================================

class AdminKycAssignment {
  const AdminKycAssignment({
    required this.id,
    required this.assignmentReference,
    required this.assignedTo,
    required this.assignedBy,
    required this.status,
    required this.priority,
    required this.assignedAt,
    this.notes,
    this.startedAt,
    this.completedAt,
    this.assignedToName,
    this.assignedByName,
  });

  final int id;
  final String assignmentReference;
  final int? assignedTo;
  final int? assignedBy;
  final String status;
  final String priority;
  final String? notes;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? assignedToName;
  final String? assignedByName;

  factory AdminKycAssignment.fromJson(Map<String, dynamic> json) {
    return AdminKycAssignment(
      id: _parseInt(json['id']),
      assignmentReference: json['assignmentReference']?.toString() ?? '',
      assignedTo: _parseNullableInt(json['assignedTo']),
      assignedBy: _parseNullableInt(json['assignedBy']),
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'normal',
      notes: json['notes']?.toString(),
      assignedAt: _parseDateTime(json['assignedAt']),
      startedAt: _parseDateTime(json['startedAt']),
      completedAt: _parseDateTime(json['completedAt']),
      assignedToName: json['assignedToName']?.toString(),
      assignedByName: json['assignedByName']?.toString(),
    );
  }
}

// ================================================================
// ASSIGNMENT RESULT
// ================================================================

class AdminKycAssignmentResult {
  const AdminKycAssignmentResult({
    required this.id,
    required this.assignmentId,
    required this.assignmentReference,
    required this.assignedTo,
    required this.priority,
    required this.status,
  });

  final int id;
  final int assignmentId;
  final String assignmentReference;
  final int assignedTo;
  final String priority;
  final String status;

  factory AdminKycAssignmentResult.fromJson(Map<String, dynamic> json) {
    return AdminKycAssignmentResult(
      id: _parseInt(json['id']),
      assignmentId: _parseInt(json['assignmentId']),
      assignmentReference: json['assignmentReference']?.toString() ?? '',
      assignedTo: _parseInt(json['assignedTo']),
      priority: json['priority']?.toString() ?? 'normal',
      status: json['status']?.toString() ?? 'assigned',
    );
  }
}

// ================================================================
// STATUS CHANGE RESULT
// ================================================================

class AdminKycStatusChangeResult {
  const AdminKycStatusChangeResult({
    required this.id,
    required this.status,
    this.previousStatus,
  });

  final int id;
  final String status;
  final String? previousStatus;

  factory AdminKycStatusChangeResult.fromJson(Map<String, dynamic> json) {
    return AdminKycStatusChangeResult(
      id: _parseInt(json['id']),
      previousStatus: json['previousStatus']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}

// ================================================================
// INFORMATION REQUEST RESULT
// ================================================================

class AdminKycInformationRequestResult {
  const AdminKycInformationRequestResult({
    required this.id,
    required this.status,
    required this.comments,
    this.previousStatus,
  });

  final int id;
  final String status;
  final String comments;
  final String? previousStatus;

  factory AdminKycInformationRequestResult.fromJson(Map<String, dynamic> json) {
    return AdminKycInformationRequestResult(
      id: _parseInt(json['id']),
      previousStatus: json['previousStatus']?.toString(),
      status: json['status']?.toString() ?? 'changes_required',
      comments: json['comments']?.toString() ?? '',
    );
  }
}

// ================================================================
// REJECTION RESULT
// ================================================================

class AdminKycRejectionResult {
  const AdminKycRejectionResult({
    required this.id,
    required this.status,
    required this.rejectionReason,
    required this.verifiedBy,
    this.previousStatus,
  });

  final int id;
  final String status;
  final String rejectionReason;
  final int verifiedBy;
  final String? previousStatus;

  factory AdminKycRejectionResult.fromJson(Map<String, dynamic> json) {
    return AdminKycRejectionResult(
      id: _parseInt(json['id']),
      previousStatus: json['previousStatus']?.toString(),
      status: json['status']?.toString() ?? 'rejected',
      rejectionReason: json['rejectionReason']?.toString() ?? '',
      verifiedBy: _parseInt(json['verifiedBy']),
    );
  }
}

// ================================================================
// PARSING HELPERS
// ================================================================

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _parseNullableInt(dynamic value) {
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

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.tryParse(value.toString());
}
