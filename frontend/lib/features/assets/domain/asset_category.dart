
class AssetCategory {
  const AssetCategory({
    required this.name,
    this.assetCount = 0,
  });

  final String name;
  final int assetCount;

  String get displayName {
    if (name.isEmpty) return '';

    return name[0].toUpperCase() + name.substring(1);
  }

  factory AssetCategory.fromJson(Map<String, dynamic> json) {
    return AssetCategory(
      name: json['category']?.toString() ?? 'other',
      assetCount: _toInt(json['assetCount']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}