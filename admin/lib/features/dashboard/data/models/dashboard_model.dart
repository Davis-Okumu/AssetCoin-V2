import '../../domain/dashboard.dart';

class DashboardModel extends Dashboard {
  const DashboardModel({
    required super.overview,
    required super.assetActivity,
    required super.assetTypes,
    required super.kycSummary,
    required super.recentTransactions,
    required super.adminActivity,
    required super.recentAssetActivity,
    required super.recentKycActivity,
    required super.transactionActivity,
    required super.userRegistrationActivity,
  });
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      overview: DashboardOverview.fromJson(_map(json['overview'])),
      assetActivity: _list(json['assetActivity'])
          .map(AssetActivityPoint.fromJson)
          .toList(),
      assetTypes: _list(json['assetTypes'])
          .map(AssetTypeSummary.fromJson)
          .toList(),
      kycSummary: _list(json['kycSummary'])
          .map(KycSummaryPoint.fromJson)
          .toList(),
      recentTransactions: _list(json['recentTransactions'])
          .map(RecentTransaction.fromJson)
          .toList(),
      adminActivity: _list(json['adminActivity'])
          .map(AdminActivity.fromJson)
          .toList(),
      recentAssetActivity: _list(json['recentAssetActivity'])
          .map(RecentAssetActivity.fromJson)
          .toList(),
      recentKycActivity: _list(json['recentKycActivity'])
          .map(RecentKycActivity.fromJson)
          .toList(),
      transactionActivity: _list(json['transactionActivity'])
          .map(TransactionActivityPoint.fromJson)
          .toList(),
      userRegistrationActivity: _list(json['userRegistrationActivity'])
          .map(RegistrationPoint.fromJson)
          .toList(),
    );
  }
  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
