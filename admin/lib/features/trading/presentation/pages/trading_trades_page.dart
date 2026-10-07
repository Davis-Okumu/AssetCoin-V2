import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_trading_trade_model.dart';
import '../../data/repositories/admin_trading_repository.dart';
import '../controllers/admin_trading_trades_controller.dart';
import '../widgets/trading_status_badge.dart';

class TradingTradesPage extends ConsumerStatefulWidget {
  const TradingTradesPage({super.key, this.onOpenTrade});

  final ValueChanged<int>? onOpenTrade;

  @override
  ConsumerState<TradingTradesPage> createState() => _TradingTradesPageState();
}

class _TradingTradesPageState extends ConsumerState<TradingTradesPage> {
  Timer? _searchDebounce;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    final controller = ref.read(adminTradingTradesControllerProvider.notifier);

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
          .read(adminTradingTradesControllerProvider.notifier)
          .search(value.trim());
    });
  }

  void _openTrade(AdminTradingTradeModel trade) {
    if (widget.onOpenTrade != null) {
      widget.onOpenTrade!(trade.id);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return _TradePreviewDialog(trade: trade);
      },
    );
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();

    ref.read(adminTradingTradesControllerProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTradingTradesControllerProvider);

    final controller = ref.read(adminTradingTradesControllerProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          _TradesHeader(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            status: controller.statusFilter,
            onStatusChanged: (value) {
              ref
                  .read(adminTradingTradesControllerProvider.notifier)
                  .setStatus(value);
            },
            onClearFilters: _clearFilters,
            onRefresh: () {
              ref.read(adminTradingTradesControllerProvider.notifier).refresh();
            },
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return _TradesError(
                  message: error.toString(),
                  onRetry: () {
                    ref
                        .read(adminTradingTradesControllerProvider.notifier)
                        .refresh();
                  },
                );
              },
              data: (result) {
                if (result.items.isEmpty) {
                  return _TradesEmpty(
                    hasFilters: _hasFilters(controller),
                    onClearFilters: _clearFilters,
                  );
                }

                return _TradesContent(
                  result: result,
                  onOpen: _openTrade,
                  onPrevious: result.hasPreviousPage
                      ? () {
                          ref
                              .read(
                                adminTradingTradesControllerProvider.notifier,
                              )
                              .previousPage();
                        }
                      : null,
                  onNext: result.hasNextPage
                      ? () {
                          ref
                              .read(
                                adminTradingTradesControllerProvider.notifier,
                              )
                              .nextPage();
                        }
                      : null,
                  onPageSizeChanged: (value) {
                    ref
                        .read(adminTradingTradesControllerProvider.notifier)
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

  bool _hasFilters(AdminTradingTradesController controller) {
    final search = controller.searchQuery;

    return (search?.trim().isNotEmpty ?? false) ||
        controller.statusFilter != null;
  }
}

class _TradesHeader extends StatelessWidget {
  const _TradesHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.status,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? status;
  final ValueChanged<String?> onStatusChanged;
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
                        'Trading Trades',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review completed and historical marketplace trades.',
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
                  width: 340,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText:
                          'Search reference, buyer, seller, token or asset...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                _StatusDropdown(value: status, onChanged: onStatusChanged),
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

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String?>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem<String?>(value: null, child: Text('All statuses')),
          DropdownMenuItem<String?>(value: 'pending', child: Text('Pending')),
          DropdownMenuItem<String?>(
            value: 'completed',
            child: Text('Completed'),
          ),
          DropdownMenuItem<String?>(value: 'failed', child: Text('Failed')),
          DropdownMenuItem<String?>(value: 'reversed', child: Text('Reversed')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _TradesContent extends StatelessWidget {
  const _TradesContent({
    required this.result,
    required this.onOpen,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
    required this.pageSize,
  });

  final AdminTradingPaginatedResult<AdminTradingTradeModel> result;
  final ValueChanged<AdminTradingTradeModel> onOpen;
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
                    DataColumn(label: Text('Trade')),
                    DataColumn(label: Text('Buyer')),
                    DataColumn(label: Text('Seller')),
                    DataColumn(label: Text('Token')),
                    DataColumn(label: Text('Asset')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Fee')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('')),
                  ],
                  rows: result.items.map((trade) {
                    return DataRow(
                      cells: [
                        DataCell(Text(_display(trade.transactionReference))),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              trade.buyerName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              trade.sellerName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(trade.tokenDisplayName)),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              trade.assetDisplayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(_display(trade.quantity))),
                        DataCell(
                          Text(
                            '${_display(trade.currency)} '
                            '${_display(trade.pricePerToken)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${_display(trade.currency)} '
                            '${_display(trade.totalAmount)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${_display(trade.currency)} '
                            '${_display(trade.feeAmount)}',
                          ),
                        ),
                        DataCell(
                          TradingStatusBadge(status: _display(trade.status)),
                        ),
                        DataCell(Text(_formatDate(trade.createdAt))),
                        DataCell(
                          IconButton(
                            tooltip: 'View trade',
                            onPressed: () => onOpen(trade),
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
            '• $total trades',
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

class _TradesEmpty extends StatelessWidget {
  const _TradesEmpty({required this.hasFilters, required this.onClearFilters});

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
              Icons.swap_horiz_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No trades match your filters' : 'No trades found',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try changing your search or status filter.'
                  : 'Completed and historical trades will appear here.',
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

class _TradesError extends StatelessWidget {
  const _TradesError({required this.message, required this.onRetry});

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
              'Unable to load trades',
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

class _TradePreviewDialog extends StatelessWidget {
  const _TradePreviewDialog({required this.trade});

  final AdminTradingTradeModel trade;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_display(trade.transactionReference)),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trade.tokenDisplayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TradingStatusBadge(status: _display(trade.status)),
                ],
              ),
              const SizedBox(height: 20),
              _PreviewRow(label: 'Buyer', value: trade.buyerName),
              _PreviewRow(label: 'Seller', value: trade.sellerName),
              _PreviewRow(label: 'Asset', value: trade.assetDisplayName),
              _PreviewRow(label: 'Quantity', value: _display(trade.quantity)),
              _PreviewRow(
                label: 'Price Per Token',
                value:
                    '${_display(trade.currency)} '
                    '${_display(trade.pricePerToken)}',
              ),
              _PreviewRow(
                label: 'Total Amount',
                value:
                    '${_display(trade.currency)} '
                    '${_display(trade.totalAmount)}',
              ),
              _PreviewRow(
                label: 'Fee',
                value:
                    '${_display(trade.currency)} '
                    '${_display(trade.feeAmount)}',
              ),
              _PreviewRow(
                label: 'Created',
                value: _formatDate(trade.createdAt),
              ),
              if (trade.hasTransactionHash) ...[
                const SizedBox(height: 8),
                _PreviewRow(
                  label: 'Transaction Hash',
                  value: _display(trade.transactionHash),
                ),
              ],
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
            width: 145,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
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
