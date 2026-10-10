import '../../../../core/network/api_client.dart';

class AdminFinanceApi {
  AdminFinanceApi(this._client);

  final ApiClient _client;

  static const String _basePath = '/api/admin/finance';

  /// Retrieves the Finance dashboard overview.
  Future<Map<String, dynamic>> getOverview() async {
    final response = await _client.get('$_basePath/overview');
    return _extractMap(response);
  }

  /// Retrieves customer wallets with optional filters and pagination.
  Future<Map<String, dynamic>> getWallets({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      '$_basePath/wallets',
      queryParameters: _normalizeQuery(queryParameters),
    );

    return _extractMap(response);
  }

  /// Retrieves wallet transactions with optional filters and pagination.
  Future<Map<String, dynamic>> getTransactions({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      '$_basePath/transactions',
      queryParameters: _normalizeQuery(queryParameters),
    );

    return _extractMap(response);
  }

  /// Retrieves deposit transactions.
  Future<Map<String, dynamic>> getDeposits({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      '$_basePath/deposits',
      queryParameters: _normalizeQuery(queryParameters),
    );

    return _extractMap(response);
  }

  /// Retrieves withdrawal transactions.
  Future<Map<String, dynamic>> getWithdrawals({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      '$_basePath/withdrawals',
      queryParameters: _normalizeQuery(queryParameters),
    );

    return _extractMap(response);
  }

  /// Retrieves reconciliation information from the backend.
  ///
  /// This endpoint requires a corresponding backend route.
  /// The supplied database schema does not define a dedicated
  /// reconciliation table.
  Future<Map<String, dynamic>> getReconciliation({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      '$_basePath/reconciliation',
      queryParameters: _normalizeQuery(queryParameters),
    );

    return _extractMap(response);
  }

  /// Retrieves details for a specific customer wallet.
  Future<Map<String, dynamic>> getWalletDetails(int walletId) async {
    final response = await _client.get('$_basePath/wallets/$walletId');

    return _extractMap(response);
  }

  /// Retrieves transactions belonging to a specific wallet.
  Future<Map<String, dynamic>> getWalletTransactions(
    int walletId, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      '$_basePath/wallets/$walletId/transactions',
      queryParameters: _normalizeQuery(queryParameters),
    );

    return _extractMap(response);
  }

  Map<String, dynamic> _normalizeQuery(Map<String, dynamic>? parameters) {
    if (parameters == null || parameters.isEmpty) {
      return <String, dynamic>{};
    }

    return parameters.map((key, value) {
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return Map<String, dynamic>.from(response);
    }

    if (response is Map) {
      final normalized = Map<String, dynamic>.from(response);
      final data = normalized['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return normalized;
    }

    throw const ApiException(message: 'Invalid Finance API response.');
  }
}
