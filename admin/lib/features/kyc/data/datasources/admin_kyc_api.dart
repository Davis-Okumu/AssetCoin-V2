import '../../../../core/network/api_client.dart';

/// API datasource for the AssetCoin Admin Dashboard KYC workflow.
///
/// This datasource is responsible only for communicating with the
/// admin KYC endpoints. Business logic belongs in the repository
/// and controllers.
class AdminKycApi {
  AdminKycApi(this._apiClient);

  final ApiClient _apiClient;

  // ============================================================
  // ENDPOINTS
  // ============================================================

  static const String _basePath = '/api/admin/kyc';

  // ============================================================
  // GET KYC APPLICATIONS
  // ============================================================

  /// Fetches the paginated list of customer KYC applications.
  ///
  /// Optional filters:
  /// - [status]
  /// - [search]
  /// - [assignedTo]
  /// - [page]
  /// - [limit]
  ///
  /// Backend:
  /// GET /api/admin/kyc
  Future<dynamic> getApplications({
    String? status,
    String? search,
    int? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (status != null && status.trim().isNotEmpty) {
      queryParameters['status'] = status.trim();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (assignedTo != null) {
      queryParameters['assignedTo'] = assignedTo;
    }

    return _apiClient.get(_basePath, queryParameters: queryParameters);
  }

  // ============================================================
  // GET KYC STATISTICS
  // ============================================================

  /// Fetches KYC dashboard statistics.
  ///
  /// Backend:
  /// GET /api/admin/kyc/stats
  Future<dynamic> getStats() async {
    return _apiClient.get('$_basePath/stats');
  }

  // ============================================================
  // GET KYC APPLICATION DETAILS
  // ============================================================

  /// Fetches the complete details of a KYC application.
  ///
  /// The response contains:
  /// - application
  /// - assignment
  /// - reviewHistory
  ///
  /// Backend:
  /// GET /api/admin/kyc/:id
  Future<dynamic> getApplication(int kycId) async {
    return _apiClient.get('$_basePath/$kycId');
  }

  // ============================================================
  // ASSIGN KYC APPLICATION
  // ============================================================

  /// Assigns a KYC application to an admin staff member.
  ///
  /// Backend:
  /// PATCH /api/admin/kyc/:id/assign
  ///
  /// Required:
  /// - [assignedTo]
  ///
  /// Optional:
  /// - [priority]
  /// - [notes]
  Future<dynamic> assignApplication({
    required int kycId,
    required int assignedTo,
    String? priority,
    String? notes,
  }) async {
    final body = <String, dynamic>{'assignedTo': assignedTo};

    if (priority != null && priority.trim().isNotEmpty) {
      body['priority'] = priority.trim();
    }

    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    return _apiClient.patch('$_basePath/$kycId/assign', body: body);
  }

  // ============================================================
  // START KYC REVIEW
  // ============================================================

  /// Moves a KYC application into the under_review state.
  ///
  /// Backend:
  /// PATCH /api/admin/kyc/:id/start-review
  Future<dynamic> startReview(int kycId) async {
    return _apiClient.patch('$_basePath/$kycId/start-review');
  }

  // ============================================================
  // REQUEST ADDITIONAL INFORMATION
  // ============================================================

  /// Requests additional information from the customer.
  ///
  /// This changes the KYC status to `changes_required`.
  ///
  /// Backend:
  /// PATCH /api/admin/kyc/:id/request-information
  ///
  /// Required:
  /// - [comments]
  Future<dynamic> requestInformation({
    required int kycId,
    required String comments,
  }) async {
    return _apiClient.patch(
      '$_basePath/$kycId/request-information',
      body: {'comments': comments.trim()},
    );
  }

  // ============================================================
  // APPROVE KYC
  // ============================================================

  /// Approves a KYC application.
  ///
  /// This changes the KYC status to `verified`.
  ///
  /// Backend:
  /// PATCH /api/admin/kyc/:id/approve
  Future<dynamic> approveApplication(int kycId) async {
    return _apiClient.patch('$_basePath/$kycId/approve');
  }

  // ============================================================
  // REJECT KYC
  // ============================================================

  /// Rejects a KYC application.
  ///
  /// Required:
  /// - [rejectionReason]
  ///
  /// Backend:
  /// PATCH /api/admin/kyc/:id/reject
  Future<dynamic> rejectApplication({
    required int kycId,
    required String rejectionReason,
  }) async {
    return _apiClient.patch(
      '$_basePath/$kycId/reject',
      body: {'rejectionReason': rejectionReason.trim()},
    );
  }
}
