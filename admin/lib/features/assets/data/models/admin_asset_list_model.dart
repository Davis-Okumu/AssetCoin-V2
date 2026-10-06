import '../../domain/admin_asset_record.dart';

class AdminAssetListModel {
  const AdminAssetListModel({
    this.items = const [],
    this.pagination = const AdminAssetPagination(),
  });

  final List<AdminAssetRecord> items;
  final AdminAssetPagination pagination;

  factory AdminAssetListModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];

    return AdminAssetListModel(
      items: itemsJson is List
          ? itemsJson
                .whereType<Map<String, dynamic>>()
                .map(AdminAssetRecord.fromJson)
                .toList()
          : const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? AdminAssetPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
          : const AdminAssetPagination(),
    );
  }
}

class AdminAssetPagination {
  const AdminAssetPagination({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory AdminAssetPagination.fromJson(Map<String, dynamic> json) {
    return AdminAssetPagination(
      page: _int(json['page'], 1),
      limit: _int(json['limit'], 20),
      total: _int(json['total']),
      totalPages: _int(json['totalPages']),
    );
  }

  bool get hasPreviousPage => page > 1;

  bool get hasNextPage => page < totalPages;
}

int _int(dynamic value, [int fallback = 0]) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
