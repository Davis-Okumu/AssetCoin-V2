import '../../../../core/network/api_client.dart';

class AdminTokenizationApi {
  AdminTokenizationApi(this._client);

  final ApiClient _client;

  static const String _basePath = '/api/admin/tokenization';

  // ============================================================
  // OVERVIEW
  // ============================================================

  Future<Map<String, dynamic>> getOverview() async {
    final response = await _client.get('$_basePath/overview');

    return _extractMap(response);
  }

  // ============================================================
  // PROPOSALS
  // ============================================================

  Future<List<dynamic>> getProposals({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '$_basePath/proposals',
      queryParameters: {'status': status, 'page': page, 'limit': limit},
    );

    return _extractList(response);
  }

  Future<Map<String, dynamic>> getProposal(int id) async {
    final response = await _client.get('$_basePath/proposals/$id');

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> createProposal(Map<String, dynamic> body) async {
    final response = await _client.post('$_basePath/proposals', body: body);

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> submitProposal(int id) async {
    final response = await _client.post('$_basePath/proposals/$id/submit');

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> reviewProposal(
    int id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      '$_basePath/proposals/$id/review',
      body: body,
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> approveProposal(
    int id, {
    String? comments,
  }) async {
    final response = await _client.post(
      '$_basePath/proposals/$id/approve',
      body: {if (comments != null) 'comments': comments},
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> rejectProposal(int id, {String? reason}) async {
    final response = await _client.post(
      '$_basePath/proposals/$id/reject',
      body: {if (reason != null) 'reason': reason},
    );

    return _extractMap(response);
  }

  // ============================================================
  // ASSIGNMENTS
  // ============================================================

  Future<List<dynamic>> getAssignments({
    int? proposalId,
    int? assignedTo,
    String? status,
    bool mine = false,
  }) async {
    final query = <String, String>{};

    if (proposalId != null) {
      query['proposalId'] = proposalId.toString();
    }

    if (assignedTo != null) {
      query['assignedTo'] = assignedTo.toString();
    }

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    if (mine) {
      query['mine'] = 'true';
    }

    final response = await _client.get(
      '$_basePath/assignments',
      queryParameters: query,
    );

    return _extractList(response);
  }

  Future<List<dynamic>> getAssignmentOfficers() async {
    final response = await _client.get('$_basePath/assignment-officers');

    return _extractList(response);
  }

  Future<Map<String, dynamic>> assignProposal(
    int proposalId, {
    required int assignedTo,
    String priority = 'normal',
    String? notes,
  }) async {
    final response = await _client.post(
      '$_basePath/proposals/$proposalId/assign',
      body: {
        'assignedTo': assignedTo,
        'priority': priority,
        if (notes != null) 'notes': notes,
      },
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> startAssignment(int assignmentId) async {
    final response = await _client.patch(
      '$_basePath/assignments/$assignmentId/start',
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> completeAssignment(
    int assignmentId, {
    String? notes,
  }) async {
    final response = await _client.patch(
      '$_basePath/assignments/$assignmentId/complete',
      body: {if (notes != null) 'notes': notes},
    );

    return _extractMap(response);
  }

  // ============================================================
  // OFFERINGS
  // ============================================================

  Future<List<dynamic>> getOfferings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '$_basePath/offerings',
      queryParameters: {'status': status, 'page': page, 'limit': limit},
    );

    return _extractList(response);
  }

  Future<Map<String, dynamic>> getOffering(int id) async {
    final response = await _client.get('$_basePath/offerings/$id');

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> activateOffering(int id) async {
    final response = await _client.patch('$_basePath/offerings/$id/activate');

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> pauseOffering(int id, {String? reason}) async {
    final response = await _client.patch(
      '$_basePath/offerings/$id/pause',
      body: {if (reason != null) 'reason': reason},
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> suspendOffering(int id, {String? reason}) async {
    final response = await _client.patch(
      '$_basePath/offerings/$id/suspend',
      body: {if (reason != null) 'reason': reason},
    );

    return _extractMap(response);
  }

  Future<Map<String, dynamic>> resumeOffering(int offeringId) async {
    final response = await _client.patch(
      '$_basePath/offerings/$offeringId/resume',
    );

    return _extractMap(response);
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException(message: 'Invalid server response.');
    }

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const ApiException(message: 'Invalid server response.');
    }

    final data = response['data'];

    if (data is List) {
      return data;
    }

    return const [];
  }
}
