import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../data/models/admin_user_list_model.dart';
import '../../data/repositories/users_repository.dart';

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(apiClient: ref.read(apiClientProvider)),
);

final usersControllerProvider =
    AsyncNotifierProvider<UsersController, AdminUserListModel>(
      UsersController.new,
    );

class UsersController extends AsyncNotifier<AdminUserListModel> {
  late final UsersRepository _repository;

  int _page = 1;
  int _limit = 20;

  String? _search;
  String? _accountStatus;
  String? _kycStatus;
  String? _role;
  String? _createdFrom;
  String? _createdTo;

  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';

  @override
  Future<AdminUserListModel> build() async {
    _repository = ref.read(usersRepositoryProvider);

    return _fetchUsers();
  }

  // =========================================================
  // CURRENT STATE
  // =========================================================

  int get page => _page;

  int get limit => _limit;

  String? get searchQuery => _search;

  String? get accountStatus => _accountStatus;

  String? get kycStatus => _kycStatus;

  String? get role => _role;

  String? get createdFrom => _createdFrom;

  String? get createdTo => _createdTo;

  String get sortBy => _sortBy;

  String get sortOrder => _sortOrder;

  // =========================================================
  // FETCH USERS
  // =========================================================

  Future<AdminUserListModel> _fetchUsers() {
    return _repository.getUsers(
      page: _page,
      limit: _limit,
      search: _search,
      accountStatus: _accountStatus,
      kycStatus: _kycStatus,
      role: _role,
      createdFrom: _createdFrom,
      createdTo: _createdTo,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshUsers() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_fetchUsers);
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Future<void> search(String value) async {
    final trimmedValue = value.trim();

    _search = trimmedValue.isEmpty ? null : trimmedValue;

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // ACCOUNT STATUS FILTER
  // =========================================================

  Future<void> setAccountStatus(String? value) async {
    final trimmedValue = value?.trim();

    _accountStatus = trimmedValue == null || trimmedValue.isEmpty
        ? null
        : trimmedValue;

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // KYC STATUS FILTER
  // =========================================================

  Future<void> setKycStatus(String? value) async {
    final trimmedValue = value?.trim();

    _kycStatus = trimmedValue == null || trimmedValue.isEmpty
        ? null
        : trimmedValue;

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // ROLE FILTER
  // =========================================================

  Future<void> setRole(String? value) async {
    final trimmedValue = value?.trim();

    _role = trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // DATE FILTERS
  // =========================================================

  Future<void> setCreatedFrom(String? value) async {
    final trimmedValue = value?.trim();

    _createdFrom = trimmedValue == null || trimmedValue.isEmpty
        ? null
        : trimmedValue;

    _page = 1;

    await refreshUsers();
  }

  Future<void> setCreatedTo(String? value) async {
    final trimmedValue = value?.trim();

    _createdTo = trimmedValue == null || trimmedValue.isEmpty
        ? null
        : trimmedValue;

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // SORTING
  // =========================================================

  Future<void> setSorting({
    required String sortBy,
    required String sortOrder,
  }) async {
    _sortBy = sortBy.trim().isEmpty ? 'createdAt' : sortBy.trim();

    _sortOrder = sortOrder.trim().toUpperCase() == 'ASC' ? 'ASC' : 'DESC';

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // CLEAR FILTERS
  // =========================================================

  Future<void> clearFilters() async {
    _search = null;
    _accountStatus = null;
    _kycStatus = null;
    _role = null;
    _createdFrom = null;
    _createdTo = null;

    _sortBy = 'createdAt';
    _sortOrder = 'DESC';

    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // PAGE SIZE
  // =========================================================

  Future<void> setLimit(int value) async {
    if (value <= 0) {
      return;
    }

    _limit = value;
    _page = 1;

    await refreshUsers();
  }

  // =========================================================
  // NEXT PAGE
  // =========================================================

  Future<void> nextPage() async {
    final current = state.value;

    if (current == null) {
      return;
    }

    if (!current.pagination.hasNextPage) {
      return;
    }

    _page++;

    await refreshUsers();
  }

  // =========================================================
  // PREVIOUS PAGE
  // =========================================================

  Future<void> previousPage() async {
    final current = state.value;

    if (current == null) {
      return;
    }

    if (!current.pagination.hasPreviousPage) {
      return;
    }

    _page--;

    if (_page < 1) {
      _page = 1;
    }

    await refreshUsers();
  }

  // =========================================================
  // GO TO PAGE
  // =========================================================

  Future<void> goToPage(int targetPage) async {
    final current = state.value;

    if (current == null) {
      return;
    }

    if (targetPage < 1) {
      return;
    }

    final totalPages = current.pagination.totalPages;

    if (totalPages > 0 && targetPage > totalPages) {
      return;
    }

    _page = targetPage;

    await refreshUsers();
  }

  // =========================================================
  // UPDATE USER
  // =========================================================

  Future<void> updateUser({
    required int userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    await _repository.updateUser(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );

    await refreshUsers();
  }

  // =========================================================
  // CHANGE USER STATUS
  // =========================================================

  Future<void> changeUserStatus({
    required int userId,
    required String accountStatus,
    String? reason,
  }) async {
    await _repository.changeUserStatus(
      userId: userId,
      accountStatus: accountStatus,
      reason: reason,
    );

    await refreshUsers();
  }
}
