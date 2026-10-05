import '../../domain/admin_user_record.dart';

class AdminUserListModel {
  const AdminUserListModel({
    required this.items,
    required this.pagination,
    required this.filters,
  });

  final List<AdminUserRecord> items;

  final UserPagination pagination;

  final UserListFilters filters;

  factory AdminUserListModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];

    final paginationJson = json['pagination'];

    final filtersJson = json['filters'];

    return AdminUserListModel(
      items: itemsJson is List
          ? itemsJson
                .whereType<Map>()
                .map(
                  (item) => AdminUserRecordModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      pagination: paginationJson is Map
          ? UserPagination.fromJson(Map<String, dynamic>.from(paginationJson))
          : const UserPagination(
              page: 1,
              limit: 20,
              total: 0,
              totalPages: 0,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
      filters: filtersJson is Map
          ? UserListFilters.fromJson(Map<String, dynamic>.from(filtersJson))
          : const UserListFilters(),
    );
  }
}

class AdminUserRecordModel extends AdminUserRecord {
  const AdminUserRecordModel({
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
  });

  factory AdminUserRecordModel.fromJson(Map<String, dynamic> json) {
    return AdminUserRecordModel(
      id: _toInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName:
          json['fullName']?.toString() ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      profilePhotoUrl: _nullableString(json['profilePhotoUrl']),
      kycStatus: json['kycStatus']?.toString() ?? 'pending',
      role: json['role']?.toString() ?? 'user',
      accountStatus: json['accountStatus']?.toString() ?? 'active',
      lastLoginAt: _parseDate(json['lastLoginAt']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class UserPagination {
  const UserPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final int page;

  final int limit;

  final int total;

  final int totalPages;

  final bool hasNextPage;

  final bool hasPreviousPage;

  factory UserPagination.fromJson(Map<String, dynamic> json) {
    return UserPagination(
      page: _toInt(json['page'], 1),
      limit: _toInt(json['limit'], 20),
      total: _toInt(json['total'], 0),
      totalPages: _toInt(json['totalPages'], 0),
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
    );
  }

  static int _toInt(dynamic value, int fallback) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class UserListFilters {
  const UserListFilters({
    this.search,
    this.accountStatus,
    this.kycStatus,
    this.role,
    this.createdFrom,
    this.createdTo,
    this.sortBy,
    this.sortOrder,
  });

  final String? search;

  final String? accountStatus;

  final String? kycStatus;

  final String? role;

  final String? createdFrom;

  final String? createdTo;

  final String? sortBy;

  final String? sortOrder;

  factory UserListFilters.fromJson(Map<String, dynamic> json) {
    return UserListFilters(
      search: _nullable(json['search']),
      accountStatus: _nullable(json['accountStatus']),
      kycStatus: _nullable(json['kycStatus']),
      role: _nullable(json['role']),
      createdFrom: _nullable(json['createdFrom']),
      createdTo: _nullable(json['createdTo']),
      sortBy: _nullable(json['sortBy']),
      sortOrder: _nullable(json['sortOrder']),
    );
  }

  static String? _nullable(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }
}
