
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/token_holding.dart';
import '../../domain/trading_repository.dart';

class TokenHoldingsState {
  final List<TokenHolding> holdings;
  final Pagination pagination;

  const TokenHoldingsState({
    required this.holdings,
    required this.pagination,
  });

  const TokenHoldingsState.initial()
      : holdings = const [],
        pagination = const Pagination(
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
        );

  bool get hasHoldings => holdings.isNotEmpty;

  bool get hasNextPage => pagination.hasNextPage;

  bool get hasPreviousPage =>
      pagination.hasPreviousPage;

  int get count => holdings.length;

  TokenHoldingsState copyWith({
    List<TokenHolding>? holdings,
    Pagination? pagination,
  }) {
    return TokenHoldingsState(
      holdings: holdings ?? this.holdings,
      pagination: pagination ?? this.pagination,
    );
  }
}

class TokenHoldingsController
    extends AsyncNotifier<TokenHoldingsState> {
  late final TradingRepository _repository;

  static const int _pageSize = 20;

  @override
  Future<TokenHoldingsState> build() async {
    _repository = ref.watch(
      TradingRepositoryImpl.provider,
    );

    return _loadHoldings(page: 1);
  }

  Future<TokenHoldingsState> _loadHoldings({
    required int page,
  }) async {
    final result =
        await _repository.getTokenHoldings(
      page: page,
      limit: _pageSize,
    );

    return TokenHoldingsState(
      holdings: result.holdings,
      pagination: result.pagination,
    );
  }

  Future<void> refreshHoldings() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadHoldings(page: 1),
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    if (!currentState.hasNextPage) {
      return;
    }

    final nextPage =
        currentState.pagination.page + 1;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadHoldings(page: nextPage),
    );
  }

  Future<void> loadPreviousPage() async {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    if (!currentState.hasPreviousPage) {
      return;
    }

    final previousPage =
        currentState.pagination.page - 1;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadHoldings(page: previousPage),
    );
  }

  Future<TokenHolding> getTokenHoldingDetails(
    int tokenId,
  ) async {
    return _repository.getTokenHoldingDetails(
      tokenId,
    );
  }

  TokenHolding? findHolding(int tokenId) {
    final currentState = state.value;

    if (currentState == null) {
      return null;
    }

    for (final holding in currentState.holdings) {
      if (holding.tokenId == tokenId) {
        return holding;
      }
    }

    return null;
  }
}

final tokenHoldingsControllerProvider =
    AsyncNotifierProvider<
      TokenHoldingsController,
      TokenHoldingsState
    >(
      TokenHoldingsController.new,
    );
