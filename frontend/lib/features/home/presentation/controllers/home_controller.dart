import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/home_summary.dart';
import '../providers/home_providers.dart';

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeSummary>(
  HomeController.new,
);

class HomeController extends AsyncNotifier<HomeSummary> {
  late final _repository = ref.read(homeRepositoryProvider);

  // LOAD HOME DATA WHEN THE PROVIDER STARTS
  @override
  Future<HomeSummary> build() async {
    return _repository.getHomeSummary();
  }

  // REFRESH HOME DATA
  Future<void> refreshHome() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getHomeSummary(),
    );
  }

  // RELOAD HOME DATA WITHOUT REPLACING THE CURRENT DATA
  Future<void> reloadHome() async {
    try {
      final updatedSummary = await _repository.getHomeSummary();

      state = AsyncData(updatedSummary);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}