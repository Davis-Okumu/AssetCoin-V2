enum WalletTransactionType {
  deposit,
  withdrawal,
  tokenPurchase,
  tokenSale,
  conversion,
  refund,
  fee,
  adjustment,
}

extension WalletTransactionTypeExtension on WalletTransactionType {
  String get value {
    switch (this) {
      case WalletTransactionType.deposit:
        return 'deposit';

      case WalletTransactionType.withdrawal:
        return 'withdrawal';

      case WalletTransactionType.tokenPurchase:
        return 'token_purchase';

      case WalletTransactionType.tokenSale:
        return 'token_sale';

      case WalletTransactionType.conversion:
        return 'conversion';

      case WalletTransactionType.refund:
        return 'refund';

      case WalletTransactionType.fee:
        return 'fee';

      case WalletTransactionType.adjustment:
        return 'adjustment';
    }
  }

  String get displayName {
    switch (this) {
      case WalletTransactionType.deposit:
        return 'Deposit';

      case WalletTransactionType.withdrawal:
        return 'Withdrawal';

      case WalletTransactionType.tokenPurchase:
        return 'Token Purchase';

      case WalletTransactionType.tokenSale:
        return 'Token Sale';

      case WalletTransactionType.conversion:
        return 'Conversion';

      case WalletTransactionType.refund:
        return 'Refund';

      case WalletTransactionType.fee:
        return 'Fee';

      case WalletTransactionType.adjustment:
        return 'Adjustment';
    }
  }

  static WalletTransactionType fromValue(String value) {
    switch (value) {
      case 'deposit':
        return WalletTransactionType.deposit;

      case 'withdrawal':
        return WalletTransactionType.withdrawal;

      case 'token_purchase':
        return WalletTransactionType.tokenPurchase;

      case 'token_sale':
        return WalletTransactionType.tokenSale;

      case 'conversion':
        return WalletTransactionType.conversion;

      case 'refund':
        return WalletTransactionType.refund;

      case 'fee':
        return WalletTransactionType.fee;

      case 'adjustment':
        return WalletTransactionType.adjustment;

      default:
        throw ArgumentError(
          'Unknown wallet transaction type: $value',
        );
    }
  }
}