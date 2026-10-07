import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_order_model.dart';
import '../../data/repositories/admin_trading_repository.dart';
import '../controllers/admin_trading_orders_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingOrdersPage extends ConsumerStatefulWidget {
  const TradingOrdersPage({super.key, this.onOpenOrder});

  final ValueChanged<int>? onOpenOrder;

  @override
  ConsumerState<TradingOrdersPage> createState() => _TradingOrdersPageState();
}

class _TradingOrdersPageState extends ConsumerState<TradingOrdersPage> {
  Timer? _searchDebounce;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    final controller = ref.read(adminTradingOrdersControllerProvider.notifier);

    _searchController.text = controller.searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }

      ref
          .read(adminTradingOrdersControllerProvider.notifier)
          .search(value.trim());
    });
  }

  void _openOrder(AdminTradingOrderModel order) {
    if (widget.onOpenOrder != null) {
      widget.onOpenOrder!(order.id);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return _OrderPreviewDialog(order: order);
      },
    );
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();

    ref.read(adminTradingOrdersControllerProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTradingOrdersControllerProvider);

    final controller = ref.read(adminTradingOrdersControllerProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          _OrdersHeader(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            status: controller.statusFilter,
            orderType: controller.orderTypeFilter,
            onStatusChanged: (value) {
              ref
                  .read(adminTradingOrdersControllerProvider.notifier)
                  .setStatus(value);
            },
            onOrderTypeChanged: (value) {
              ref
                  .read(adminTradingOrdersControllerProvider.notifier)
                  .setOrderType(value);
            },
            onClearFilters: _clearFilters,
            onRefresh: () {
              ref.read(adminTradingOrdersControllerProvider.notifier).refresh();
            },
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return _OrdersError(
                  message: error.toString(),
                  onRetry: () {
                    ref
                        .read(adminTradingOrdersControllerProvider.notifier)
                        .refresh();
                  },
                );
              },
              data: (result) {
                if (result.items.isEmpty) {
                  return _OrdersEmpty(
                    hasFilters: _hasFilters(controller),
                    onClearFilters: _clearFilters,
                  );
                }

                return _OrdersContent(
                  result: result,
                  onOpen: _openOrder,
                  onPrevious: result.hasPreviousPage
                      ? () {
                          ref
                              .read(
                                adminTradingOrdersControllerProvider.notifier,
                              )
                              .previousPage();
                        }
                      : null,
                  onNext: result.hasNextPage
                      ? () {
                          ref
                              .read(
                                adminTradingOrdersControllerProvider.notifier,
                              )
                              .nextPage();
                        }
                      : null,
                  onPageSizeChanged: (value) {
                    ref
                        .read(adminTradingOrdersControllerProvider.notifier)
                        .setPageSize(value);
                  },
                  pageSize: result.limit,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _hasFilters(AdminTradingOrdersController controller) {
    final search = controller.searchQuery;

    return (search?.trim().isNotEmpty ?? false) ||
        controller.statusFilter != null ||
        controller.orderTypeFilter != null;
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.status,
    required this.orderType,
    required this.onStatusChanged,
    required this.onOrderTypeChanged,
    required this.onClearFilters,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? status;
  final String? orderType;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onOrderTypeChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trading Orders',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor and review marketplace orders.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search order, customer, token or asset...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                _FilterDropdown(
                  value: status,
                  label: 'Status',
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
                _FilterDropdown(
                  value: orderType,
                  label: 'Order Type',
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All types'),
                    ),
                    DropdownMenuItem<String?>(value: 'buy', child: Text('Buy')),
                    DropdownMenuItem<String?>(
                      value: 'sell',
                      child: Text('Sell'),
                    ),
                  ],
                  onChanged: onOrderTypeChanged,
                ),
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String label;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String?>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({
    required this.result,
    required this.onOpen,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
    required this.pageSize,
  });

  final AdminTradingPaginatedResult<AdminTradingOrderModel> result;
  final ValueChanged<AdminTradingOrderModel> onOpen;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSizeChanged;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Order')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Token')),
                    DataColumn(label: Text('Asset')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('')),
                  ],
                  rows: result.items.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(Text(_display(order.orderReference))),
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: Text(
                              order.customerName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(order.tokenDisplayName)),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              order.assetDisplayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(order.orderTypeLabel)),
                        DataCell(Text(_display(order.quantity))),
                        DataCell(
                          Text(
                            '${_display(order.currency)} '
                            '${_display(order.totalAmount)}',
                          ),
                        ),
                        DataCell(
                          TradingStatusBadge(status: _display(order.status)),
                        ),
                        DataCell(Text(_formatDate(order.createdAt))),
                        DataCell(
                          IconButton(
                            tooltip: 'View order',
                            onPressed: () => onOpen(order),
                            icon: const Icon(Icons.open_in_new),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        _Pagination(
          page: result.page,
          totalPages: result.totalPages,
          total: result.total,
          pageSize: pageSize,
          onPrevious: onPrevious,
          onNext: onNext,
          onPageSizeChanged: onPageSizeChanged,
        ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  });

  final int page;
  final int totalPages;
  final int total;
  final int pageSize;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        children: [
          Text(
            'Page $page of ${totalPages == 0 ? 1 : totalPages} '
            '• $total orders',
          ),
          const Spacer(),
          const Text('Rows:'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _allowedPageSize(pageSize),
            items: const [
              DropdownMenuItem(value: 10, child: Text('10')),
              DropdownMenuItem(value: 20, child: Text('20')),
              DropdownMenuItem(value: 50, child: Text('50')),
              DropdownMenuItem(value: 100, child: Text('100')),
            ],
            onChanged: (value) {
              if (value != null) {
                onPageSizeChanged(value);
              }
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Previous page',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  int _allowedPageSize(int value) {
    const allowed = [10, 20, 50, 100];

    if (allowed.contains(value)) {
      return value;
    }

    return 20;
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty({required this.hasFilters, required this.onClearFilters});

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No orders match your filters'
                  : 'No trading orders found',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try changing your search or filters.'
                  : 'Trading orders will appear here when available.',
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60),
            const SizedBox(height: 16),
            Text(
              'Unable to load orders',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPreviewDialog extends StatelessWidget {
  const _OrderPreviewDialog({required this.order});

  final AdminTradingOrderModel order;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_display(order.orderReference)),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TradingStatusBadge(status: _display(order.status)),
                ],
              ),
              const SizedBox(height: 20),
              _PreviewRow(label: 'Order Type', value: order.orderTypeLabel),
              _PreviewRow(label: 'Token', value: order.tokenDisplayName),
              _PreviewRow(label: 'Asset', value: order.assetDisplayName),
              _PreviewRow(label: 'Quantity', value: _display(order.quantity)),
              _PreviewRow(
                label: 'Filled Quantity',
                value: _display(order.filledQuantity),
              ),
              _PreviewRow(
                label: 'Price Per Token',
                value:
                    '${_display(order.currency)} '
                    '${_display(order.pricePerToken)}',
              ),
              _PreviewRow(
                label: 'Total Amount',
                value:
                    '${_display(order.currency)} '
                    '${_display(order.totalAmount)}',
              ),
              _PreviewRow(
                label: 'Created',
                value: _formatDate(order.createdAt),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _display(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '—';
  }

  return value;
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '—';
  }

  final local = value.toLocal();

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  return '${local.year}-'
      '${twoDigits(local.month)}-'
      '${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:'
      '${twoDigits(local.minute)}';
}
