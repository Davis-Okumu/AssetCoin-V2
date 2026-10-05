class UserActivity {
  const UserActivity({
    this.loginActivity = const [],
    this.walletTransactions = const [],
    this.assets = const [],
    this.adminAudit = const [],
  });

  final List<LoginActivity> loginActivity;

  final List<UserWalletActivity> walletTransactions;

  final List<UserAssetActivity> assets;

  final List<UserAdminAuditActivity> adminAudit;
}

class LoginActivity {
  const LoginActivity({
    required this.id,
    required this.eventType,
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.userAgent,
    required this.description,
    required this.createdAt,
  });

  final int id;

  final String? eventType;

  final String? deviceName;

  final String? deviceType;

  final String? ipAddress;

  final String? userAgent;

  final String? description;

  final DateTime? createdAt;
}

class UserWalletActivity {
  const UserWalletActivity({
    required this.id,
    required this.transactionReference,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    required this.description,
    required this.transactionHash,
    required this.createdAt,
  });

  final int id;

  final String? transactionReference;

  final String? transactionType;

  final String? amount;

  final String? currency;

  final String? balanceBefore;

  final String? balanceAfter;

  final String? status;

  final String? description;

  final String? transactionHash;

  final DateTime? createdAt;
}

class UserAssetActivity {
  const UserAssetActivity({
    required this.id,
    required this.assetCode,
    required this.assetType,
    required this.name,
    required this.estimatedValue,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;

  final String? assetCode;

  final String? assetType;

  final String? name;

  final String? estimatedValue;

  final String? currency;

  final String? status;

  final DateTime? createdAt;

  final DateTime? updatedAt;
}

class UserAdminAuditActivity {
  const UserAdminAuditActivity({
    required this.id,
    required this.action,
    required this.module,
    required this.entityType,
    required this.entityId,
    required this.oldValues,
    required this.newValues,
    required this.createdAt,
  });

  final int id;

  final String? action;

  final String? module;

  final String? entityType;

  final String? entityId;

  final dynamic oldValues;

  final dynamic newValues;

  final DateTime? createdAt;
}
