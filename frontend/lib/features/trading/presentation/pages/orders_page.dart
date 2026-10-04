
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/orders_controller.dart';
import '../widgets/order_card.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(
      ordersControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return _OrdersErrorView(
            message: error.toString(),
            onRetry: () {
              ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .refreshOrders();
            },
          );
        },
        data: (ordersState) {
          return _OrdersContent(
            state: ordersState,
            onRefresh: () {
              return ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .refreshOrders();
            },
            onStatusChanged: (status) {
              return ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .setStatus(status);
            },
            onOrderTypeChanged: (orderType) {
              return ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .setOrderType(orderType);
            },
            onClearFilters: () {
              return ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .clearFilters();
            },
            onNextPage: () {
              return ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .loadNextPage();
            },
            onPreviousPage: () {
              return ref
                  .read(
                    ordersControllerProvider.notifier,
                  )
                  .loadPreviousPage();
            },
          );
        },
      ),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  final OrdersState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String?) onStatusChanged;
  final Future<void> Function(String?) onOrderTypeChanged;
  final Future<void> Function() onClearFilters;
  final Future<void> Function() onNextPage;
  final Future<void> Function() onPreviousPage;

  const _OrdersContent({
    required this.state,
    required this.onRefresh,
    required this.onStatusChanged,
    required this.onOrderTypeChanged,
    required this.onClearFilters,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _OrdersHeader(
              orderCount: state.pagination.total,
              buyCount: state.buyOrders.length,
              sellCount: state.sellOrders.length,
            ),
          ),

          SliverToBoxAdapter(
            child: _OrderFilters(
              selectedStatus: state.status,
              selectedOrderType: state.orderType,
              onStatusChanged: onStatusChanged,
              onOrderTypeChanged: onOrderTypeChanged,
              onClearFilters: onClearFilters,
            ),
          ),

          if (!state.hasOrders)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyOrdersView(),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = state.orders[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: OrderCard(
                        order: order,
                        onTap: () {
                          context.push(
                            '/trading/orders/${order.id}',
                          );
                        },
                      ),
                    );
                  },
                  childCount: state.orders.length,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _PaginationControls(
                state: state,
                onPreviousPage: onPreviousPage,
                onNextPage: onNextPage,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  final int orderCount;
  final int buyCount;
  final int sellCount;

  const _OrdersHeader({
    required this.orderCount,
    required this.buyCount,
    required this.sellCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary
                      .withValues(alpha: 0.16),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Your Orders',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color:
                            colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '$orderCount total orders',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: colorScheme.onPrimary
                      .withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeaderStat(
                label: 'Buy',
                value: buyCount,
              ),
              const SizedBox(width: 24),
              _HeaderStat(
                label: 'Sell',
                value: sellCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final int value;

  const _HeaderStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: colorScheme.onPrimary
                    .withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: colorScheme.onPrimary
                .withValues(alpha: 0.16),
            borderRadius:
                BorderRadius.circular(999),
          ),
          child: Text(
            '$value',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _OrderFilters extends StatelessWidget {
  final String? selectedStatus;
  final String? selectedOrderType;
  final Future<void> Function(String?) onStatusChanged;
  final Future<void> Function(String?) onOrderTypeChanged;
  final Future<void> Function() onClearFilters;

  const _OrderFilters({
    required this.selectedStatus,
    required this.selectedOrderType,
    required this.onStatusChanged,
    required this.onOrderTypeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final hasFilters =
        selectedStatus != null ||
        selectedOrderType != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter orders',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              if (hasFilters)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChoiceChip(
                  label: 'All',
                  selected:
                      selectedOrderType == null,
                  onSelected: (_) {
                    onOrderTypeChanged(null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChoiceChip(
                  label: 'Buy',
                  selected:
                      selectedOrderType == 'buy',
                  onSelected: (_) {
                    onOrderTypeChanged('buy');
                  },
                ),
                const SizedBox(width: 8),
                _FilterChoiceChip(
                  label: 'Sell',
                  selected:
                      selectedOrderType == 'sell',
                  onSelected: (_) {
                    onOrderTypeChanged('sell');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            value: selectedStatus,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Order status',
              prefixIcon: const Icon(
                Icons.flag_outlined,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.outline
                      .withValues(alpha: 0.45),
                ),
              ),
            ),
            items: const [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('All statuses'),
              ),
              DropdownMenuItem<String?>(
                value: 'pending',
                child: Text('Pending'),
              ),
              DropdownMenuItem<String?>(
                value: 'open',
                child: Text('Open'),
              ),
              DropdownMenuItem<String?>(
                value: 'partially_filled',
                child: Text('Partially Filled'),
              ),
              DropdownMenuItem<String?>(
                value: 'filled',
                child: Text('Filled'),
              ),
              DropdownMenuItem<String?>(
                value: 'cancelled',
                child: Text('Cancelled'),
              ),
              DropdownMenuItem<String?>(
                value: 'rejected',
                child: Text('Rejected'),
              ),
              DropdownMenuItem<String?>(
                value: 'expired',
                child: Text('Expired'),
              ),
            ],
            onChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: selected
          ? const Icon(
              Icons.check_rounded,
              size: 18,
            )
          : null,
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final OrdersState state;
  final Future<void> Function() onPreviousPage;
  final Future<void> Function() onNextPage;

  const _PaginationControls({
    required this.state,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline
                .withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous page',
              onPressed: state.hasPreviousPage
                  ? onPreviousPage
                  : null,
              icon: const Icon(
                Icons.chevron_left_rounded,
              ),
            ),
            Expanded(
              child: Text(
                'Page ${state.pagination.page}'
                ' of ${state.pagination.totalPages == 0 ? 1 : state.pagination.totalPages}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: state.hasNextPage
                  ? onNextPage
                  : null,
              icon: const Icon(
                Icons.chevron_right_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colorScheme.primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No orders found',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your buy and sell orders will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrdersErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load orders',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
