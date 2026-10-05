import '../../domain/admin_user_record.dart';

class UserDetailsModel extends AdminUserRecord {
  const UserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.kycStatus,
    required super.role,
    required super.accountStatus,
    super.profilePhotoUrl,
    super.lastLoginAt,
    super.createdAt,
    super.updatedAt,
    this.nationalId,
    this.idDocumentUrl,
    this.wallet,
    this.summary = const UserDetailsSummary(),
  });

  final String? nationalId;

  final String? idDocumentUrl;

  final UserWalletSummary? wallet;

  final UserDetailsSummary summary;

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: _toInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName:
          json['fullName']?.toString() ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: _nullable(json['email']),
      phone: _nullable(json['phone']),
      profilePhotoUrl: _nullable(json['profilePhotoUrl']),
      nationalId: _nullable(json['nationalId']),
      idDocumentUrl: _nullable(json['idDocumentUrl']),
      kycStatus: json['kycStatus']?.toString() ?? 'pending',
      role: json['role']?.toString() ?? 'user',
      accountStatus: json['accountStatus']?.toString() ?? 'active',
      lastLoginAt: _date(json['lastLoginAt']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      wallet: json['wallet'] is Map
          ? UserWalletSummary.fromJson(
              Map<String, dynamic>.from(json['wallet']),
            )
          : null,
      summary: json['summary'] is Map
          ? UserDetailsSummary.fromJson(
              Map<String, dynamic>.from(json['summary']),
            )
          : const UserDetailsSummary(),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullable(dynamic value) {
    final text = value?.toString().trim();

    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class UserWalletSummary {
  const UserWalletSummary({
    required this.id,
    required this.walletAddress,
    required this.fiatBalance,
    required this.lockedFiatBalance,
    required this.currency,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;

  final String? walletAddress;

  final String fiatBalance;

  final String lockedFiatBalance;

  final String currency;

  final String status;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  factory UserWalletSummary.fromJson(Map<String, dynamic> json) {
    return UserWalletSummary(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      walletAddress: json['walletAddress']?.toString(),
      fiatBalance: json['fiatBalance']?.toString() ?? '0',
      lockedFiatBalance: json['lockedFiatBalance']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? 'KES',
      status: json['status']?.toString() ?? 'unknown',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class UserDetailsSummary {
  const UserDetailsSummary({
    this.assets = const UserAssetSummary(),
    this.holdings = const UserHoldingSummary(),
    this.support = const UserSupportSummary(),
  });

  final UserAssetSummary assets;

  final UserHoldingSummary holdings;

  final UserSupportSummary support;

  factory UserDetailsSummary.fromJson(Map<String, dynamic> json) {
    return UserDetailsSummary(
      assets: json['assets'] is Map
          ? UserAssetSummary.fromJson(Map<String, dynamic>.from(json['assets']))
          : const UserAssetSummary(),
      holdings: json['holdings'] is Map
          ? UserHoldingSummary.fromJson(
              Map<String, dynamic>.from(json['holdings']),
            )
          : const UserHoldingSummary(),
      support: json['support'] is Map
          ? UserSupportSummary.fromJson(
              Map<String, dynamic>.from(json['support']),
            )
          : const UserSupportSummary(),
    );
  }
}

class UserAssetSummary {
  const UserAssetSummary({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.tokenized = 0,
  });

  final int total;

  final int pending;

  final int approved;

  final int tokenized;

  factory UserAssetSummary.fromJson(Map<String, dynamic> json) {
    return UserAssetSummary(
      total: _int(json['total']),
      pending: _int(json['pending']),
      approved: _int(json['approved']),
      tokenized: _int(json['tokenized']),
    );
  }

  static int _int(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class UserHoldingSummary {
  const UserHoldingSummary({
    this.totalTokens = 0,
    this.quantity = '0',
    this.totalInvested = '0',
  });

  final int totalTokens;

  final String quantity;

  final String totalInvested;

  factory UserHoldingSummary.fromJson(Map<String, dynamic> json) {
    return UserHoldingSummary(
      totalTokens: int.tryParse(json['totalTokens']?.toString() ?? '') ?? 0,
      quantity: json['quantity']?.toString() ?? '0',
      totalInvested: json['totalInvested']?.toString() ?? '0',
    );
  }
}

class UserSupportSummary {
  const UserSupportSummary({this.totalTickets = 0, this.openTickets = 0});

  final int totalTickets;

  final int openTickets;

  factory UserSupportSummary.fromJson(Map<String, dynamic> json) {
    return UserSupportSummary(
      totalTickets: int.tryParse(json['totalTickets']?.toString() ?? '') ?? 0,
      openTickets: int.tryParse(json['openTickets']?.toString() ?? '') ?? 0,
    );
  }
}
