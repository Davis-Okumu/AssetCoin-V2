import '../datasources/admin_finance_api.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class FinanceRepository {
  FinanceRepository(this._api);

  final AdminFinanceApi _api;

  Future<WalletModel> getWalletDetails(int walletId) async {
    final response = await _api.getWalletDetails(walletId);

    final wallet = _findWalletObject(response);

    return WalletModel.fromJson(wallet);
  }

  Future<List<WalletTransactionModel>> getWalletTransactions(
    int walletId, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _api.getWalletTransactions(
      walletId,
      queryParameters: queryParameters,
    );

    final rows = _extractTransactions(response);

    return rows.map(WalletTransactionModel.fromJson).toList();
  }

  Map<String, dynamic> _findWalletObject(Map<String, dynamic> response) {
    final wallet = response['wallet'];

    if (wallet is Map) {
      return Map<String, dynamic>.from(wallet);
    }

    final data = response['data'];

    if (data is Map) {
      final nestedWallet = data['wallet'];

      if (nestedWallet is Map) {
        return Map<String, dynamic>.from(nestedWallet);
      }

      return Map<String, dynamic>.from(data);
    }

    return response;
  }

  List<Map<String, dynamic>> _extractTransactions(
    Map<String, dynamic> response,
  ) {
    final candidates = <dynamic>[
      response['transactions'],
      response['items'],
      response['results'],
      response['data'],
    ];

    final data = response['data'];

    if (data is Map) {
      candidates.add(data['transactions']);
      candidates.add(data['items']);
      candidates.add(data['results']);
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
