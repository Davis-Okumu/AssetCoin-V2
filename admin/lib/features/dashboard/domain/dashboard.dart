class Dashboard {
  final DashboardOverview overview;
  final List<AssetActivityPoint> assetActivity;
  final List<AssetTypeSummary> assetTypes;
  final List<KycSummaryPoint> kycSummary;
  final List<RecentTransaction> recentTransactions;
  final List<AdminActivity> adminActivity;
  final List<RecentAssetActivity> recentAssetActivity;
  final List<RecentKycActivity> recentKycActivity;
  final List<TransactionActivityPoint> transactionActivity;
  final List<RegistrationPoint> userRegistrationActivity;
  const Dashboard({
    required this.overview,
    required this.assetActivity,
    required this.assetTypes,
    required this.kycSummary,
    required this.recentTransactions,
    required this.adminActivity,
    required this.recentAssetActivity,
    required this.recentKycActivity,
    required this.transactionActivity,
    required this.userRegistrationActivity,
  });
}

class DashboardOverview {
  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int newUsersLast30Days;
  final int totalKyc;
  final int pendingKyc;
  final int underReviewKyc;
  final int verifiedKyc;
  final int rejectedKyc;
  final int totalAssets;
  final double totalAssetValue;
  final int pendingAssets;
  final int assetsUnderReview;
  final int assetsChangesRequired;
  final int approvedAssets;
  final int tokenizedAssets;
  final int rejectedAssets;
  final int suspendedAssets;
  final int totalTokens;
  final double totalTokenSupply;
  final double availableTokenSupply;
  final int activeTokens;
  final int pendingTokens;
  final int pausedTokens;
  final int totalWallets;
  final double totalWalletBalance;
  final double totalLockedWalletBalance;
  final int activeWallets;
  final int frozenWallets;
  final int activeListings;
  final int pendingOrders;
  final int completedTransactions;
  final double tradingVolume;
  final double tradingFees;
  final int transactionsLast30Days;
  final int pendingApprovals;
  final int activeAssignments;
  final int openSupportTickets;
  final int unreadAdminNotifications;
  const DashboardOverview({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.suspendedUsers = 0,
    this.newUsersLast30Days = 0,
    this.totalKyc = 0,
    this.pendingKyc = 0,
    this.underReviewKyc = 0,
    this.verifiedKyc = 0,
    this.rejectedKyc = 0,
    this.totalAssets = 0,
    this.totalAssetValue = 0,
    this.pendingAssets = 0,
    this.assetsUnderReview = 0,
    this.assetsChangesRequired = 0,
    this.approvedAssets = 0,
    this.tokenizedAssets = 0,
    this.rejectedAssets = 0,
    this.suspendedAssets = 0,
    this.totalTokens = 0,
    this.totalTokenSupply = 0,
    this.availableTokenSupply = 0,
    this.activeTokens = 0,
    this.pendingTokens = 0,
    this.pausedTokens = 0,
    this.totalWallets = 0,
    this.totalWalletBalance = 0,
    this.totalLockedWalletBalance = 0,
    this.activeWallets = 0,
    this.frozenWallets = 0,
    this.activeListings = 0,
    this.pendingOrders = 0,
    this.completedTransactions = 0,
    this.tradingVolume = 0,
    this.tradingFees = 0,
    this.transactionsLast30Days = 0,
    this.pendingApprovals = 0,
    this.activeAssignments = 0,
    this.openSupportTickets = 0,
    this.unreadAdminNotifications = 0,
  });
  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalUsers: _int(json['totalUsers']),
      activeUsers: _int(json['activeUsers']),
      suspendedUsers: _int(json['suspendedUsers']),
      newUsersLast30Days: _int(json['newUsersLast30Days']),
      totalKyc: _int(json['totalKyc']),
      pendingKyc: _int(json['pendingKyc']),
      underReviewKyc: _int(json['underReviewKyc']),
      verifiedKyc: _int(json['verifiedKyc']),
      rejectedKyc: _int(json['rejectedKyc']),
      totalAssets: _int(json['totalAssets']),
      totalAssetValue: _double(json['totalAssetValue']),
      pendingAssets: _int(json['pendingAssets']),
      assetsUnderReview: _int(json['assetsUnderReview']),
      assetsChangesRequired: _int(json['assetsChangesRequired']),
      approvedAssets: _int(json['approvedAssets']),
      tokenizedAssets: _int(json['tokenizedAssets']),
      rejectedAssets: _int(json['rejectedAssets']),
      suspendedAssets: _int(json['suspendedAssets']),
      totalTokens: _int(json['totalTokens']),
      totalTokenSupply: _double(json['totalTokenSupply']),
      availableTokenSupply: _double(json['availableTokenSupply']),
      activeTokens: _int(json['activeTokens']),
      pendingTokens: _int(json['pendingTokens']),
      pausedTokens: _int(json['pausedTokens']),
      totalWallets: _int(json['totalWallets']),
      totalWalletBalance: _double(json['totalWalletBalance']),
      totalLockedWalletBalance: _double(json['totalLockedWalletBalance']),
      activeWallets: _int(json['activeWallets']),
      frozenWallets: _int(json['frozenWallets']),
      activeListings: _int(json['activeListings']),
      pendingOrders: _int(json['pendingOrders']),
      completedTransactions: _int(json['completedTransactions']),
      tradingVolume: _double(json['tradingVolume']),
      tradingFees: _double(json['tradingFees']),
      transactionsLast30Days: _int(json['transactionsLast30Days']),
      pendingApprovals: _int(json['pendingApprovals']),
      activeAssignments: _int(json['activeAssignments']),
      openSupportTickets: _int(json['openSupportTickets']),
      unreadAdminNotifications: _int(json['unreadAdminNotifications']),
    );
  }
}

class AssetActivityPoint {
  final String label;
  final DateTime? date;
  final int count;
  final double totalValue;
  const AssetActivityPoint({
    this.label = '',
    this.date,
    this.count = 0,
    this.totalValue = 0,
  });
  factory AssetActivityPoint.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['createdAt'] ?? json['period'];
    return AssetActivityPoint(
      label: _label(rawDate),
      date: _date(rawDate),
      count: _int(json['count']),
      totalValue: _double(json['totalValue'] ?? json['value']),
    );
  }
}

class AssetTypeSummary {
  final String type;
  final int count;
  final double totalValue;
  const AssetTypeSummary({
    this.type = 'Unknown',
    this.count = 0,
    this.totalValue = 0,
  });
  factory AssetTypeSummary.fromJson(Map<String, dynamic> json) {
    return AssetTypeSummary(
      type: _string(
        json['assetType'] ?? json['type'] ?? json['name'],
        fallback: 'Unknown',
      ),
      count: _int(json['count']),
      totalValue: _double(json['totalValue'] ?? json['value']),
    );
  }
}

class KycSummaryPoint {
  final String status;
  final int count;
  const KycSummaryPoint({this.status = 'Unknown', this.count = 0});
  factory KycSummaryPoint.fromJson(Map<String, dynamic> json) {
    return KycSummaryPoint(
      status: _string(json['status'], fallback: 'Unknown'),
      count: _int(json['count']),
    );
  }
}

class RecentTransaction {
  final dynamic id;
  final String reference;
  final String type;
  final String status;
  final String userName;
  final double amount;
  final double feeAmount;
  final String currency;
  final DateTime? createdAt;
  const RecentTransaction({
    this.id,
    this.reference = '',
    this.type = 'Transaction',
    this.status = 'unknown',
    this.userName = '',
    this.amount = 0,
    this.feeAmount = 0,
    this.currency = 'KES',
    this.createdAt,
  });
  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'],
      reference: _string(
        json['reference'] ?? json['transactionReference'] ?? json['id'],
      ),
      type: _string(
        json['transactionType'] ?? json['type'],
        fallback: 'Transaction',
      ),
      status: _string(json['status'], fallback: 'unknown'),
      userName: _string(
        json['userName'] ?? json['customerName'] ?? json['name'],
      ),
      amount: _double(json['totalAmount'] ?? json['amount'] ?? json['volume']),
      feeAmount: _double(json['feeAmount'] ?? json['fee']),
      currency: _string(json['currency'], fallback: 'KES'),
      createdAt: _date(json['createdAt'] ?? json['timestamp']),
    );
  }
}

class AdminActivity {
  final dynamic id;
  final String action;
  final String module;
  final String staffName;
  final String entityType;
  final dynamic entityId;
  final DateTime? createdAt;
  const AdminActivity({
    this.id,
    this.action = '',
    this.module = '',
    this.staffName = '',
    this.entityType = '',
    this.entityId,
    this.createdAt,
  });
  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      id: json['id'],
      action: _string(json['action'], fallback: 'Activity'),
      module: _string(json['module']),
      staffName: _string(
        json['staffName'] ?? json['adminName'] ?? json['name'],
      ),
      entityType: _string(json['entityType']),
      entityId: json['entityId'],
      createdAt: _date(json['createdAt'] ?? json['timestamp']),
    );
  }
}

class RecentAssetActivity {
  final dynamic id;
  final String name;
  final String assetType;
  final String status;
  final String ownerName;
  final DateTime? createdAt;
  const RecentAssetActivity({
    this.id,
    this.name = '',
    this.assetType = '',
    this.status = '',
    this.ownerName = '',
    this.createdAt,
  });
  factory RecentAssetActivity.fromJson(Map<String, dynamic> json) {
    return RecentAssetActivity(
      id: json['id'],
      name: _string(
        json['name'] ?? json['assetName'] ?? json['title'],
        fallback: 'Asset',
      ),
      assetType: _string(json['assetType'] ?? json['type'], fallback: 'Asset'),
      status: _string(json['status']),
      ownerName: _string(
        json['ownerName'] ?? json['userName'] ?? json['customerName'],
      ),
      createdAt: _date(json['createdAt'] ?? json['updatedAt']),
    );
  }
}

class RecentKycActivity {
  final dynamic id;
  final String userName;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  const RecentKycActivity({
    this.id,
    this.userName = '',
    this.status = '',
    this.submittedAt,
    this.reviewedAt,
  });
  factory RecentKycActivity.fromJson(Map<String, dynamic> json) {
    return RecentKycActivity(
      id: json['id'],
      userName: _string(
        json['userName'] ?? json['customerName'] ?? json['name'],
        fallback: 'User',
      ),
      status: _string(json['status'] ?? json['kycStatus']),
      submittedAt: _date(json['submittedAt'] ?? json['createdAt']),
      reviewedAt: _date(json['reviewedAt'] ?? json['updatedAt']),
    );
  }
}

class TransactionActivityPoint {
  final String label;
  final DateTime? date;
  final double volume;
  final int transactionCount;
  const TransactionActivityPoint({
    this.label = '',
    this.date,
    this.volume = 0,
    this.transactionCount = 0,
  });
  factory TransactionActivityPoint.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['createdAt'] ?? json['period'];
    return TransactionActivityPoint(
      label: _label(rawDate),
      date: _date(rawDate),
      volume: _double(json['volume'] ?? json['totalAmount'] ?? json['value']),
      transactionCount: _int(json['transactionCount'] ?? json['count']),
    );
  }
}

class RegistrationPoint {
  final String label;
  final DateTime? date;
  final int count;
  const RegistrationPoint({this.label = '', this.date, this.count = 0});
  factory RegistrationPoint.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['createdAt'] ?? json['period'];
    return RegistrationPoint(
      label: _label(rawDate),
      date: _date(rawDate),
      count: _int(json['count']),
    );
  }
}

int _int(dynamic value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _string(dynamic value, {String fallback = ''}) {
  final result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

DateTime? _date(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString())?.toLocal();
}

String _label(dynamic value) {
  if (value == null) {
    return '';
  }
  final date = _date(value);
  if (date != null) {
    return '${date.day}/${date.month}';
  }
  return value.toString();
}
