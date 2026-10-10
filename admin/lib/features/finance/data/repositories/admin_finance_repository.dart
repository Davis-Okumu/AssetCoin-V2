import '../datasources/admin_finance_api.dart';
import '../models/finance_deposit_model.dart';
import '../models/finance_overview_model.dart';
import '../models/finance_reconciliation_model.dart';
import '../models/finance_transaction_model.dart';
import '../models/finance_wallet_model.dart';
import '../models/finance_withdrawal_model.dart';

class AdminFinanceRepository {
  AdminFinanceRepository(this._api);

  final AdminFinanceApi _api;

  Future<FinanceOverviewModel> getOverview() async {
    final response = await _api.getOverview();

    return FinanceOverviewModel.fromJson(
      _unwrapObject(response, const ['overview', 'summary']),
    );
  }

  Future<List<FinanceWalletModel>> getWallets({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _api.getWallets(queryParameters: queryParameters);

    return _extractList(response, const [
      'wallets',
      'items',
      'results',
    ]).map(FinanceWalletModel.fromJson).toList();
  }

  Future<List<FinanceTransactionModel>> getTransactions({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _api.getTransactions(
      queryParameters: queryParameters,
    );

    return _extractList(response, const [
      'transactions',
      'items',
      'results',
    ]).map(FinanceTransactionModel.fromJson).toList();
  }

  Future<List<FinanceDepositModel>> getDeposits({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _api.getDeposits(queryParameters: queryParameters);

    return _extractList(response, const [
      'deposits',
      'items',
      'results',
    ]).map(FinanceDepositModel.fromJson).toList();
  }

  Future<List<FinanceWithdrawalModel>> getWithdrawals({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _api.getWithdrawals(
      queryParameters: queryParameters,
    );

    return _extractList(response, const [
      'withdrawals',
      'items',
      'results',
    ]).map(FinanceWithdrawalModel.fromJson).toList();
  }

  Future<List<FinanceReconciliationModel>> getReconciliation({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _api.getReconciliation(
      queryParameters: queryParameters,
    );

    return _extractList(response, const [
      'reconciliation',
      'records',
      'items',
      'results',
    ]).map(FinanceReconciliationModel.fromJson).toList();
  }

  Map<String, dynamic> _unwrapObject(
    Map<String, dynamic> response,
    List<String> preferredKeys,
  ) {
    for (final key in preferredKeys) {
      final value = response[key];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    final data = response['data'];

    if (data is Map) {
      for (final key in preferredKeys) {
        final value = data[key];

        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      }

      return Map<String, dynamic>.from(data);
    }

    return response;
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> response,
    List<String> preferredKeys,
  ) {
    final candidates = <dynamic>[
      for (final key in preferredKeys) response[key],
      response['data'],
    ];

    final data = response['data'];

    if (data is Map) {
      for (final key in preferredKeys) {
        candidates.add(data[key]);
      }

      candidates.add(data['data']);
    }

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return <Map<String, dynamic>>[];
  }
}
