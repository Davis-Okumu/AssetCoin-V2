import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_details_model.dart';
import '../../data/models/user_session_model.dart';
import '../../data/repositories/users_repository.dart';
import 'users_controller.dart';

final userDetailsControllerProvider =
    AsyncNotifierProvider<UserDetailsController, UserDetailsState>(
      UserDetailsController.new,
    );

class UserDetailsState {
  const UserDetailsState({required this.user, this.activity});

  final UserDetailsModel user;

  final UserActivityModel? activity;

  UserDetailsState copyWith({
    UserDetailsModel? user,
    UserActivityModel? activity,
  }) {
    return UserDetailsState(
      user: user ?? this.user,
      activity: activity ?? this.activity,
    );
  }
}

class UserDetailsController extends AsyncNotifier<UserDetailsState> {
  late final UsersRepository _repository;

  int? _userId;

  @override
  Future<UserDetailsState> build() async {
    _repository = ref.read(usersRepositoryProvider);

    if (_userId == null) {
      throw StateError('No user has been selected.');
    }

    final user = await _repository.getUser(_userId!);

    return UserDetailsState(user: user);
  }

  int? get userId => _userId;

  // =========================================================
  // SELECT AND LOAD USER
  // =========================================================

  Future<void> loadUser(int id) async {
    _userId = id;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = await _repository.getUser(id);

      return UserDetailsState(user: user);
    });
  }

  // =========================================================
  // REFRESH USER
  // =========================================================

  Future<void> refreshUser() async {
    final id = _userId;

    if (id == null) {
      return;
    }

    final previousActivity = state.value?.activity;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = await _repository.getUser(id);

      return UserDetailsState(user: user, activity: previousActivity);
    });
  }

  // =========================================================
  // LOAD USER ACTIVITY
  // =========================================================

  Future<void> loadActivity() async {
    final id = _userId;
    final current = state.value;

    if (id == null || current == null) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final activity = await _repository.getUserActivity(id);

      return current.copyWith(activity: activity);
    });
  }

  // =========================================================
  // UPDATE USER
  // =========================================================

  Future<void> updateUser({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
  }) async {
    final id = _userId;

    if (id == null) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = await _repository.updateUser(
        userId: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      return UserDetailsState(user: user);
    });
  }

  // =========================================================
  // CHANGE USER STATUS
  // =========================================================

  Future<void> changeStatus({
    required String accountStatus,
    String? reason,
  }) async {
    final id = _userId;

    if (id == null) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = await _repository.changeUserStatus(
        userId: id,
        accountStatus: accountStatus,
        reason: reason,
      );

      return UserDetailsState(user: user);
    });
  }

  // =========================================================
  // CLEAR USER
  // =========================================================

  void clearUser() {
    _userId = null;
    state = const AsyncLoading();
  }
}
