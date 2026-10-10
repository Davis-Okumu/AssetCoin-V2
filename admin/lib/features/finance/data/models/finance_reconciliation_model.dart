class FinanceReconciliationModel {
  const FinanceReconciliationModel({
    required this.reference,
    required this.status,
    this.expectedAmount,
    this.actualAmount,
    this.currency = 'KES',
    this.transactionCount,
    this.matchedCount,
    this.unmatchedCount,
    this.difference,
    this.startedAt,
    this.completedAt,
    this.notes,
  });

  final String reference;
  final String status;
  final double? expectedAmount;
  final double? actualAmount;
  final String currency;
  final int? transactionCount;
  final int? matchedCount;
  final int? unmatchedCount;
  final double? difference;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;

  double get calculatedDifference {
    if (difference != null) return difference!;
    if (expectedAmount == null || actualAmount == null) return 0;
    return actualAmount! - expectedAmount!;
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isBalanced => calculatedDifference.abs() < 0.005;

  factory FinanceReconciliationModel.fromJson(Map<String, dynamic> json) {
    return FinanceReconciliationModel(
      reference:
          (json['reference'] ??
                  json['reconciliationReference'] ??
                  json['reconciliation_reference'] ??
                  '')
              .toString(),
      status: (json['status'] ?? 'pending').toString(),
      expectedAmount: _toNullableDouble(
        json['expectedAmount'] ?? json['expected_amount'],
      ),
      actualAmount: _toNullableDouble(
        json['actualAmount'] ?? json['actual_amount'],
      ),
      currency: (json['currency'] ?? 'KES').toString(),
      transactionCount: _toNullableInt(
        json['transactionCount'] ?? json['transaction_count'],
      ),
      matchedCount: _toNullableInt(
        json['matchedCount'] ?? json['matched_count'],
      ),
      unmatchedCount: _toNullableInt(
        json['unmatchedCount'] ?? json['unmatched_count'],
      ),
      difference: _toNullableDouble(
        json['difference'] ?? json['discrepancyAmount'],
      ),
      startedAt: _toDate(json['startedAt'] ?? json['started_at']),
      completedAt: _toDate(json['completedAt'] ?? json['completed_at']),
      notes: _toNullableString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'status': status,
      'expectedAmount': expectedAmount,
      'actualAmount': actualAmount,
      'currency': currency,
      'transactionCount': transactionCount,
      'matchedCount': matchedCount,
      'unmatchedCount': unmatchedCount,
      'difference': difference,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _toNullableString(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}

DateTime? _toDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}
