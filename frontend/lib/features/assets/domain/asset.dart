
class Asset {
  const Asset({
    required this.id,
    required this.assetCode,
    required this.assetType,
    required this.name,
    required this.estimatedValue,
    required this.currency,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.registrationNumber,
    this.status,
    this.primaryPhoto,
    this.token,
    this.photos = const [],
    this.priceHistory = const [],
    this.createdAt,
  });

  final int id;
  final String assetCode;
  final String assetType;
  final String name;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? registrationNumber;
  final double estimatedValue;
  final String currency;
  final String? status;
  final String? primaryPhoto;
  final AssetToken? token;
  final List<AssetPhoto> photos;
  final List<AssetPricePoint> priceHistory;
  final DateTime? createdAt;

  factory Asset.fromJson(Map<String, dynamic> json) {
    final tokenId = _toInt(json['tokenId']);

    final hasToken = tokenId > 0 ||
        json['tokenCode'] != null;

    return Asset(
      id: _toInt(json['id']),
      assetCode: json['assetCode']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? 'other',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      latitude: _toNullableDouble(json['latitude']),
      longitude: _toNullableDouble(json['longitude']),
      registrationNumber:
          json['registrationNumber']?.toString(),
      estimatedValue: _toDouble(json['estimatedValue']),
      currency: json['currency']?.toString() ?? 'KES',
      status: json['status']?.toString(),
      primaryPhoto: json['primaryPhoto']?.toString(),
      token: hasToken ? AssetToken.fromJson(json) : null,
      photos: _parseList(
        json['photos'],
        AssetPhoto.fromJson,
      ),
      priceHistory: _parseList(
        json['priceHistory'],
        AssetPricePoint.fromJson,
      ),
      createdAt: _toDateTime(json['createdAt']),
    );
  }

  static List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map(
          (item) => fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;

    return _toDouble(value);
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

// =====================================================
// ASSET TOKEN
// =====================================================

class AssetToken {
  const AssetToken({
    required this.id,
    required this.tokenCode,
    required this.tokenName,
    required this.totalSupply,
    required this.availableSupply,
    required this.tokenPrice,
    required this.currency,
    required this.status,
    this.description,
    this.decimals,
    this.mintedAt,
  });

  final int id;
  final String tokenCode;
  final String tokenName;
  final String? description;
  final double totalSupply;
  final double availableSupply;
  final double tokenPrice;
  final String currency;
  final int? decimals;
  final String status;
  final DateTime? mintedAt;

  factory AssetToken.fromJson(Map<String, dynamic> json) {
    return AssetToken(
      id: Asset._toInt(json['tokenId']),
      tokenCode: json['tokenCode']?.toString() ?? '',
      tokenName: json['tokenName']?.toString() ?? '',
      description: json['tokenDescription']?.toString(),
      totalSupply: Asset._toDouble(json['totalSupply']),
      availableSupply:
          Asset._toDouble(json['availableSupply']),
      tokenPrice: Asset._toDouble(json['tokenPrice']),
      currency:
          json['tokenCurrency']?.toString() ??
          json['currency']?.toString() ??
          'KES',
      decimals: json['decimals'] == null
          ? null
          : Asset._toInt(json['decimals']),
      status: json['tokenStatus']?.toString() ?? '',
      mintedAt: Asset._toDateTime(json['mintedAt']),
    );
  }
}

// =====================================================
// ASSET PHOTO
// =====================================================

class AssetPhoto {
  const AssetPhoto({
    required this.id,
    required this.photoUrl,
    required this.isPrimary,
    required this.displayOrder,
  });

  final int id;
  final String photoUrl;
  final bool isPrimary;
  final int displayOrder;

  factory AssetPhoto.fromJson(Map<String, dynamic> json) {
    return AssetPhoto(
      id: Asset._toInt(json['id']),
      photoUrl: json['photoUrl']?.toString() ?? '',
      isPrimary: json['isPrimary'] == true ||
          json['isPrimary'] == 1 ||
          json['isPrimary']?.toString() == '1',
      displayOrder: Asset._toInt(json['displayOrder']),
    );
  }
}

// =====================================================
// ASSET PRICE HISTORY
// =====================================================

class AssetPricePoint {
  const AssetPricePoint({
    required this.price,
    required this.currency,
    required this.source,
    required this.recordedAt,
  });

  final double price;
  final String currency;
  final String source;
  final DateTime? recordedAt;

  factory AssetPricePoint.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssetPricePoint(
      price: Asset._toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'KES',
      source: json['source']?.toString() ?? '',
      recordedAt: Asset._toDateTime(json['recordedAt']),
    );
  }
}