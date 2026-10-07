class AdminTradingOverviewModel {
  const AdminTradingOverviewModel({
    required this.listings,
    required this.orders,
    required this.trades,
    required this.disputes,
    required this.suspendedListings,
    required this.recentTrades,
    required this.recentDisputes,
  });

  final AdminTradingListingsSummary listings;
  final AdminTradingOrdersSummary orders;
  final AdminTradingTradesSummary trades;
  final AdminTradingDisputesSummary disputes;

  final int suspendedListings;

  final List<Map<String, dynamic>> recentTrades;
  final List<Map<String, dynamic>> recentDisputes;

  factory AdminTradingOverviewModel.fromJson(Map<String, dynamic> json) {
    return AdminTradingOverviewModel(
      listings: AdminTradingListingsSummary.fromJson(_asMap(json['listings'])),
      orders: AdminTradingOrdersSummary.fromJson(_asMap(json['orders'])),
      trades: AdminTradingTradesSummary.fromJson(_asMap(json['trades'])),
      disputes: AdminTradingDisputesSummary.fromJson(_asMap(json['disputes'])),
      suspendedListings: _asInt(json['suspendedListings']),
      recentTrades: _asMapList(json['recentTrades']),
      recentDisputes: _asMapList(json['recentDisputes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listings': listings.toJson(),
      'orders': orders.toJson(),
      'trades': trades.toJson(),
      'disputes': disputes.toJson(),
      'suspendedListings': suspendedListings,
      'recentTrades': recentTrades,
      'recentDisputes': recentDisputes,
    };
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ================================================================
// LISTINGS SUMMARY
// ================================================================

class AdminTradingListingsSummary {
  const AdminTradingListingsSummary({
    required this.total,
    required this.active,
    required this.suspended,
    required this.filled,
  });

  final int total;
  final int active;
  final int suspended;
  final int filled;

  factory AdminTradingListingsSummary.fromJson(Map<String, dynamic> json) {
    return AdminTradingListingsSummary(
      total: _asInt(json['total']),
      active: _asInt(json['active']),
      suspended: _asInt(json['suspended']),
      filled: _asInt(json['filled']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'suspended': suspended,
      'filled': filled,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ================================================================
// ORDERS SUMMARY
// ================================================================

class AdminTradingOrdersSummary {
  const AdminTradingOrdersSummary({
    required this.total,
    required this.open,
    required this.completed,
    required this.cancelled,
  });

  final int total;
  final int open;
  final int completed;
  final int cancelled;

  factory AdminTradingOrdersSummary.fromJson(Map<String, dynamic> json) {
    return AdminTradingOrdersSummary(
      total: _asInt(json['total']),
      open: _asInt(json['open']),
      completed: _asInt(json['completed']),
      cancelled: _asInt(json['cancelled']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'open': open,
      'completed': completed,
      'cancelled': cancelled,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ================================================================
// TRADES SUMMARY
// ================================================================

class AdminTradingTradesSummary {
  const AdminTradingTradesSummary({
    required this.total,
    required this.completed,
    required this.volume,
    required this.fees,
  });

  final int total;
  final int completed;

  /// Kept as String because MySQL DECIMAL values are returned
  /// by the backend as decimal strings.
  final String volume;

  /// Kept as String because MySQL DECIMAL values are returned
  /// by the backend as decimal strings.
  final String fees;

  factory AdminTradingTradesSummary.fromJson(Map<String, dynamic> json) {
    return AdminTradingTradesSummary(
      total: _asInt(json['total']),
      completed: _asInt(json['completed']),
      volume: _asDecimalString(json['volume']),
      fees: _asDecimalString(json['fees']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
      'volume': volume,
      'fees': fees,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _asDecimalString(dynamic value) {
    if (value == null) {
      return '0.00';
    }

    return value.toString();
  }
}

// ================================================================
// DISPUTES SUMMARY
// ================================================================

class AdminTradingDisputesSummary {
  const AdminTradingDisputesSummary({
    required this.total,
    required this.open,
    required this.resolved,
    required this.rejected,
  });

  final int total;
  final int open;
  final int resolved;
  final int rejected;

  factory AdminTradingDisputesSummary.fromJson(Map<String, dynamic> json) {
    return AdminTradingDisputesSummary(
      total: _asInt(json['total']),
      open: _asInt(json['open']),
      resolved: _asInt(json['resolved']),
      rejected: _asInt(json['rejected']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'open': open,
      'resolved': resolved,
      'rejected': rejected,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
