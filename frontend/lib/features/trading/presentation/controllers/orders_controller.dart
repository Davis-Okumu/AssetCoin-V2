
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/order.dart';
import '../../domain/trading_repository.dart';

class OrdersState {
  final List<TradingOrder> orders;
  final Pagination pagination;
  final String? status;
  final String? orderType;

  const OrdersState({
    required this.orders,
    required this.pagination,
    this.status,
    this.orderType,
  });

  const OrdersState.initial()
      : orders = const [],
        pagination = const Pagination(
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
        ),
        status = null,
        orderType = null;

  bool get hasOrders => orders.isNotEmpty;

  bool get hasNextPage => pagination.hasNextPage;

  bool get hasPreviousPage =>
      pagination.hasPreviousPage;

  List<TradingOrder> get buyOrders {
    return orders
        .where(
          (order) =>
              order.orderType.toLowerCase() == 'buy',
        )
        .toList();
  }

  List<TradingOrder> get sellOrders {
    return orders
        .where(
          (order) =>
              order.orderType.toLowerCase() == 'sell',
        )
        .toList();
  }

  OrdersState copyWith({
    List<TradingOrder>? orders,
    Pagination? pagination,
    String? status,
    String? orderType,
    bool clearStatus = false,
    bool clearOrderType = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      pagination: pagination ?? this.pagination,
      status: clearStatus
          ? null
          : status ?? this.status,
      orderType: clearOrderType
          ? null
          : orderType ?? this.orderType,
    );
  }
}

class OrdersController
    extends AsyncNotifier<OrdersState> {
  late final TradingRepository _repository;

  static const int _pageSize = 20;

  @override
  Future<OrdersState> build() async {
    _repository = ref.watch(
      TradingRepositoryImpl.provider,
    );

    return _loadOrders(
      page: 1,
      status: null,
      orderType: null,
    );
  }

  Future<OrdersState> _loadOrders({
    required int page,
    required String? status,
    required String? orderType,
  }) async {
    final result = await _repository.getOrders(
      page: page,
      limit: _pageSize,
      status: _normalizeFilter(status),
      orderType: _normalizeOrderType(orderType),
    );

    return OrdersState(
      orders: result.orders,
      pagination: result.pagination,
      status: status,
      orderType: orderType,
    );
  }

  Future<void> refreshOrders() async {
    final currentState = state.value;

    final status = currentState?.status;
    final orderType = currentState?.orderType;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadOrders(
        page: 1,
        status: status,
        orderType: orderType,
      ),
    );
  }

  Future<void> setStatus(String? status) async {
    final currentState = state.value;

    final orderType = currentState?.orderType;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadOrders(
        page: 1,
        status: _normalizeFilter(status),
        orderType: orderType,
      ),
    );
  }

  Future<void> setOrderType(
    String? orderType,
  ) async {
    final currentState = state.value;

    final status = currentState?.status;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadOrders(
        page: 1,
        status: status,
        orderType: _normalizeOrderType(orderType),
      ),
    );
  }

  Future<void> clearFilters() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _loadOrders(
        page: 1,
        status: null,
        orderType: null,
      ),
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
      () => _loadOrders(
        page: nextPage,
        status: currentState.status,
        orderType: currentState.orderType,
      ),
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
      () => _loadOrders(
        page: previousPage,
        status: currentState.status,
        orderType: currentState.orderType,
      ),
    );
  }

  Future<TradingOrder> getOrderDetails(
    int orderId,
  ) async {
    return _repository.getOrderDetails(orderId);
  }

  String? _normalizeFilter(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty || normalized == 'all') {
      return null;
    }

    return normalized;
  }

  String? _normalizeOrderType(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty || normalized == 'all') {
      return null;
    }

    if (normalized != 'buy' &&
        normalized != 'sell') {
      return null;
    }

    return normalized;
  }
}

final ordersControllerProvider =
    AsyncNotifierProvider<
      OrdersController,
      OrdersState
    >(
      OrdersController.new,
    );
