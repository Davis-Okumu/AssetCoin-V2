class TokenizationOverviewModel {
  const TokenizationOverviewModel({
    required this.totalProposals,
    required this.pendingReview,
    required this.changesRequired,
    required this.pendingApproval,
    required this.approved,
    required this.rejected,
    required this.totalOfferings,
    required this.activeOfferings,
    required this.pausedOfferings,
    required this.suspendedOfferings,
  });

  final int totalProposals;
  final int pendingReview;
  final int changesRequired;
  final int pendingApproval;
  final int approved;
  final int rejected;

  final int totalOfferings;
  final int activeOfferings;
  final int pausedOfferings;
  final int suspendedOfferings;

  factory TokenizationOverviewModel.fromJson(Map<String, dynamic> json) {
    return TokenizationOverviewModel(
      totalProposals: _toInt(json['totalProposals']),
      pendingReview: _toInt(json['pendingReview']),
      changesRequired: _toInt(json['changesRequired']),
      pendingApproval: _toInt(json['pendingApproval']),
      approved: _toInt(json['approved']),
      rejected: _toInt(json['rejected']),
      totalOfferings: _toInt(json['totalOfferings']),
      activeOfferings: _toInt(json['activeOfferings']),
      pausedOfferings: _toInt(json['pausedOfferings']),
      suspendedOfferings: _toInt(json['suspendedOfferings']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
