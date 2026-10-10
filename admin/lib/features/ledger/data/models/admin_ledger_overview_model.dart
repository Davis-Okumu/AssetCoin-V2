import 'admin_ledger_entry_model.dart';

class AdminLedgerOverviewModel {
  const AdminLedgerOverviewModel({
    required this.summary,
    required this.totalsByAssetAndType,
    required this.recentEntries,
    required this.readOnly,
    this.note,
  });

  final AdminLedgerSummaryModel summary;
  final List<AdminLedgerAssetTotalModel> totalsByAssetAndType;
  final List<AdminLedgerEntryModel> recentEntries;
  final bool readOnly;
  final String? note;

  factory AdminLedgerOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawSummary = _map(json['summary']);
    final rawTotals = json['totalsByAssetAndType'];
    final rawEntries = json['recentEntries'];

    return AdminLedgerOverviewModel(
      summary: AdminLedgerSummaryModel.fromJson(rawSummary),
      totalsByAssetAndType: rawTotals is List
          ? rawTotals
                .whereType<Map>()
                .map(
                  (item) => AdminLedgerAssetTotalModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      recentEntries: rawEntries is List
          ? rawEntries
                .whereType<Map>()
                .map(
                  (item) => AdminLedgerEntryModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      readOnly: json['readOnly'] == true,
      note: json['note']?.toString(),
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

class AdminLedgerSummaryModel {
  const AdminLedgerSummaryModel({
    required this.totalEntries,
    required this.debitEntries,
    required this.creditEntries,
    required this.fiatEntries,
    required this.tokenEntries,
    required this.entriesWithoutPreviousHash,
    required this.entriesWithoutHash,
    this.firstEntryAt,
    this.latestEntryAt,
  });

  final int totalEntries;
  final int debitEntries;
  final int creditEntries;
  final int fiatEntries;
  final int tokenEntries;
  final int entriesWithoutPreviousHash;
  final int entriesWithoutHash;
  final DateTime? firstEntryAt;
  final DateTime? latestEntryAt;

  factory AdminLedgerSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminLedgerSummaryModel(
      totalEntries: _int(json['totalEntries']),
      debitEntries: _int(json['debitEntries']),
      creditEntries: _int(json['creditEntries']),
      fiatEntries: _int(json['fiatEntries']),
      tokenEntries: _int(json['tokenEntries']),
      entriesWithoutPreviousHash: _int(json['entriesWithoutPreviousHash']),
      entriesWithoutHash: _int(json['entriesWithoutHash']),
      firstEntryAt: _date(json['firstEntryAt']),
      latestEntryAt: _date(json['latestEntryAt']),
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _date(dynamic value) {
    if (value is DateTime) return value;
    return value == null ? null : DateTime.tryParse(value.toString());
  }
}

class AdminLedgerAssetTotalModel {
  const AdminLedgerAssetTotalModel({
    required this.assetType,
    required this.entryType,
    required this.currency,
    required this.entryCount,
    required this.totalAmount,
  });

  final String assetType;
  final String entryType;
  final String currency;
  final int entryCount;
  final String totalAmount;

  factory AdminLedgerAssetTotalModel.fromJson(Map<String, dynamic> json) {
    return AdminLedgerAssetTotalModel(
      assetType: json['assetType']?.toString() ?? '',
      entryType: json['entryType']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      entryCount: _int(json['entryCount']),
      totalAmount: json['totalAmount']?.toString() ?? '0',
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get assetTypeLabel => _titleCase(assetType);
  String get entryTypeLabel => _titleCase(entryType);

  static String _titleCase(String value) {
    final normalized = value.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return value;

    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
