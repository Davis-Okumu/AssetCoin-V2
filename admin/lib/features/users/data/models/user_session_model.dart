import 'dart:convert';

import '../../domain/user_session.dart';

class UserActivityModel extends UserActivity {
  const UserActivityModel({
    super.loginActivity,
    super.walletTransactions,
    super.assets,
    super.adminAudit,
  });

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      loginActivity: _list(json['loginActivity'], LoginActivityModel.fromJson),
      walletTransactions: _list(
        json['walletTransactions'],
        UserWalletActivityModel.fromJson,
      ),
      assets: _list(json['assets'], UserAssetActivityModel.fromJson),
      adminAudit: _list(
        json['adminAudit'],
        UserAdminAuditActivityModel.fromJson,
      ),
    );
  }

  static List<T> _list<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => parser(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class LoginActivityModel extends LoginActivity {
  const LoginActivityModel({
    required super.id,
    required super.eventType,
    required super.deviceName,
    required super.deviceType,
    required super.ipAddress,
    required super.userAgent,
    required super.description,
    required super.createdAt,
  });

  factory LoginActivityModel.fromJson(Map<String, dynamic> json) {
    return LoginActivityModel(
      id: _int(json['id']),
      eventType: _string(json['eventType']),
      deviceName: _string(json['deviceName']),
      deviceType: _string(json['deviceType']),
      ipAddress: _string(json['ipAddress']),
      userAgent: _string(json['userAgent']),
      description: _string(json['description']),
      createdAt: _date(json['createdAt']),
    );
  }

  static int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static String? _string(dynamic value) => value?.toString();

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}

class UserWalletActivityModel extends UserWalletActivity {
  const UserWalletActivityModel({
    required super.id,
    required super.transactionReference,
    required super.transactionType,
    required super.amount,
    required super.currency,
    required super.balanceBefore,
    required super.balanceAfter,
    required super.status,
    required super.description,
    required super.transactionHash,
    required super.createdAt,
  });

  factory UserWalletActivityModel.fromJson(Map<String, dynamic> json) {
    return UserWalletActivityModel(
      id: _int(json['id']),
      transactionReference: _string(json['transactionReference']),
      transactionType: _string(json['transactionType']),
      amount: _string(json['amount']),
      currency: _string(json['currency']),
      balanceBefore: _string(json['balanceBefore']),
      balanceAfter: _string(json['balanceAfter']),
      status: _string(json['status']),
      description: _string(json['description']),
      transactionHash: _string(json['transactionHash']),
      createdAt: _date(json['createdAt']),
    );
  }

  static int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static String? _string(dynamic value) => value?.toString();

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}

class UserAssetActivityModel extends UserAssetActivity {
  const UserAssetActivityModel({
    required super.id,
    required super.assetCode,
    required super.assetType,
    required super.name,
    required super.estimatedValue,
    required super.currency,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserAssetActivityModel.fromJson(Map<String, dynamic> json) {
    return UserAssetActivityModel(
      id: _int(json['id']),
      assetCode: _string(json['assetCode']),
      assetType: _string(json['assetType']),
      name: _string(json['name']),
      estimatedValue: _string(json['estimatedValue']),
      currency: _string(json['currency']),
      status: _string(json['status']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  static int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static String? _string(dynamic value) => value?.toString();

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}

class UserAdminAuditActivityModel extends UserAdminAuditActivity {
  const UserAdminAuditActivityModel({
    required super.id,
    required super.action,
    required super.module,
    required super.entityType,
    required super.entityId,
    required super.oldValues,
    required super.newValues,
    required super.createdAt,
  });

  factory UserAdminAuditActivityModel.fromJson(Map<String, dynamic> json) {
    return UserAdminAuditActivityModel(
      id: _int(json['id']),
      action: _string(json['action']),
      module: _string(json['module']),
      entityType: _string(json['entityType']),
      entityId: _string(json['entityId']),
      oldValues: _decodeJson(json['oldValues']),
      newValues: _decodeJson(json['newValues']),
      createdAt: _date(json['createdAt']),
    );
  }

  static dynamic _decodeJson(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map || value is List) {
      return value;
    }

    try {
      return jsonDecode(value.toString());
    } catch (_) {
      return value;
    }
  }

  static int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static String? _string(dynamic value) => value?.toString();

  static DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
