import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/wallet_repository.dart';
import '../domain/wallet_summary.dart';
import '../domain/wallet_transaction.dart';

class WalletRepositoryImpl implements WalletRepository {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  WalletRepositoryImpl({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  String get _baseUrl => AppEnv.apiBaseUrl;

  // ============================================================
  // AUTHENTICATED REQUEST HEADERS
  // ============================================================

  Future<Map<String, String>> _authenticatedHeaders() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      throw WalletApiException(
        message: 'Your session has expired. Please log in again.',
        statusCode: 401,
      );
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  // ============================================================
  // GET WALLET SUMMARY
  // ============================================================

  @override
  Future<WalletSummary> getWalletSummary() async {
    final headers = await _authenticatedHeaders();

    final response = await _client.get(
      Uri.parse('$_baseUrl/api/wallet'),
      headers: headers,
    );

    final responseData = _decodeResponse(response);

    if (_isSuccessful(response, responseData)) {
      return WalletSummary.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    }

    throw _createException(
      response,
      responseData,
      fallbackMessage: 'Unable to retrieve your wallet.',
    );
  }

  // ============================================================
  // GET TRANSACTIONS
  // ============================================================

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    final headers = await _authenticatedHeaders();

    final response = await _client.get(
      Uri.parse('$_baseUrl/api/wallet/transactions'),
      headers: headers,
    );

    final responseData = _decodeResponse(response);

    if (_isSuccessful(response, responseData)) {
      final data = responseData['data'];

      if (data is List) {
        return data
            .map(
              (item) => WalletTransaction.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      if (data is Map<String, dynamic> && data['transactions'] is List) {
        return (data['transactions'] as List)
            .map(
              (item) => WalletTransaction.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      return [];
    }

    throw _createException(
      response,
      responseData,
      fallbackMessage: 'Unable to retrieve wallet transactions.',
    );
  }

  // ============================================================
  // GET SINGLE TRANSACTION
  // ============================================================

  @override
  Future<WalletTransaction> getTransaction(
    int transactionId,
  ) async {
    final headers = await _authenticatedHeaders();

    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/api/wallet/transactions/$transactionId',
      ),
      headers: headers,
    );

    final responseData = _decodeResponse(response);

    if (_isSuccessful(response, responseData)) {
      final data = responseData['data'];

      if (data is Map<String, dynamic> &&
          data['transaction'] is Map<String, dynamic>) {
        return WalletTransaction.fromJson(
          data['transaction'] as Map<String, dynamic>,
        );
      }

      return WalletTransaction.fromJson(
        data as Map<String, dynamic>,
      );
    }

    throw _createException(
      response,
      responseData,
      fallbackMessage: 'Unable to retrieve this transaction.',
    );
  }

  // ============================================================
  // DEPOSIT
  // ============================================================

  @override
  Future<WalletTransaction> deposit({
    required double amount,
  }) async {
    final headers = await _authenticatedHeaders();

    final response = await _client.post(
      Uri.parse('$_baseUrl/api/wallet/deposits'),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
      }),
    );

    final responseData = _decodeResponse(response);

    if (_isSuccessful(response, responseData)) {
      return _transactionFromResponse(
        responseData,
        fallbackMessage: 'Unable to create the deposit request.',
      );
    }

    throw _createException(
      response,
      responseData,
      fallbackMessage: 'Unable to create the deposit request.',
    );
  }

  // ============================================================
  // WITHDRAW
  // ============================================================

  @override
  Future<WalletTransaction> withdraw({
    required double amount,
  }) async {
    final headers = await _authenticatedHeaders();

    final response = await _client.post(
      Uri.parse('$_baseUrl/api/wallet/withdrawals'),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
      }),
    );

    final responseData = _decodeResponse(response);

    if (_isSuccessful(response, responseData)) {
      return _transactionFromResponse(
        responseData,
        fallbackMessage: 'Unable to create the withdrawal request.',
      );
    }

    throw _createException(
      response,
      responseData,
      fallbackMessage: 'Unable to create the withdrawal request.',
    );
  }

  // ============================================================
  // CONVERSION
  // ============================================================

  @override
  Future<WalletTransaction> convert({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    final headers = await _authenticatedHeaders();

    final response = await _client.post(
      Uri.parse('$_baseUrl/api/wallet/conversions'),
      headers: headers,
      body: jsonEncode({
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'amount': amount,
      }),
    );

    final responseData = _decodeResponse(response);

    if (_isSuccessful(response, responseData)) {
      return _transactionFromResponse(
        responseData,
        fallbackMessage: 'Unable to create the conversion request.',
      );
    }

    throw _createException(
      response,
      responseData,
      fallbackMessage: 'Unable to create the conversion request.',
    );
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': false,
        'message': 'Invalid server response.',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Invalid server response.',
      };
    }
  }

  bool _isSuccessful(
    http.Response response,
    Map<String, dynamic> responseData,
  ) {
    return response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true;
  }

  WalletTransaction _transactionFromResponse(
    Map<String, dynamic> responseData, {
    required String fallbackMessage,
  }) {
    final data = responseData['data'];

    if (data is Map<String, dynamic> &&
        data['transaction'] is Map<String, dynamic>) {
      return WalletTransaction.fromJson(
        data['transaction'] as Map<String, dynamic>,
      );
    }

    if (data is Map<String, dynamic>) {
      return WalletTransaction.fromJson(data);
    }

    throw WalletApiException(
      message: fallbackMessage,
      statusCode: 500,
    );
  }

  WalletApiException _createException(
    http.Response response,
    Map<String, dynamic> responseData, {
    required String fallbackMessage,
  }) {
    return WalletApiException(
      message:
          responseData['message'] as String? ?? fallbackMessage,
      statusCode: response.statusCode,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _client.close();
  }
}

// ================================================================
// WALLET API EXCEPTION
// ================================================================

class WalletApiException implements Exception {
  const WalletApiException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}