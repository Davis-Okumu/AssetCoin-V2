import 'package:flutter/material.dart';

import '../../data/models/admin_trading_listing_model.dart';
import 'trading_status_badge.dart';

class TradingListingTable extends StatelessWidget {
  const TradingListingTable({
    super.key,
    required this.items,
    required this.onOpen,
    this.onSuspend,
    this.onReactivate,
  });

  final List<AdminTradingListingModel> items;

  final ValueChanged<AdminTradingListingModel> onOpen;
  final ValueChanged<AdminTradingListingModel>? onSuspend;
  final ValueChanged<AdminTradingListingModel>? onReactivate;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowHeight: 52,
          dataRowMinHeight: 64,
          dataRowMaxHeight: 76,
          columns: const [
            DataColumn(label: Text('Listing')),
            DataColumn(label: Text('Asset')),
            DataColumn(label: Text('Seller')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Quantity'), numeric: true),
            DataColumn(label: Text('Price / Token'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: items.map((item) {
            return DataRow(
              onSelectChanged: (_) => onOpen(item),
              cells: [
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.tokenDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '#${item.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Text(
                      item.assetDisplayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      item.sellerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(item.listingTypeLabel)),
                DataCell(Text(item.remainingQuantity)),
                DataCell(Text('${item.currency} ${item.pricePerToken}')),
                DataCell(TradingStatusBadge(status: item.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Open listing',
                        onPressed: () => onOpen(item),
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                      if (item.canSuspend && onSuspend != null)
                        IconButton(
                          tooltip: 'Suspend listing',
                          onPressed: () => onSuspend!(item),
                          icon: const Icon(Icons.pause_circle_outline),
                        ),
                      if (item.canReactivate && onReactivate != null)
                        IconButton(
                          tooltip: 'Reactivate listing',
                          onPressed: () => onReactivate!(item),
                          icon: const Icon(Icons.play_circle_outline),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
