import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/admin_asset_list_model.dart';
import 'asset_status_badge.dart';

class AssetsTable extends StatelessWidget {
  const AssetsTable({super.key, required this.data});

  final AdminAssetListModel data;

  @override
  Widget build(BuildContext context) {
    if (data.items.isEmpty) {
      return Card(
        elevation: 0,
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 52,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No assets found',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try adjusting your search or filters.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 28,
          headingRowHeight: 54,
          dataRowMinHeight: 68,
          dataRowMaxHeight: 76,
          columns: const [
            DataColumn(label: Text('Asset')),
            DataColumn(label: Text('Owner')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Value')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Reviews')),
            DataColumn(label: Text('Action')),
          ],
          rows: data.items.map((asset) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          asset.assetCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                DataCell(
                  SizedBox(
                    width: 170,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (asset.owner?.email != null)
                          Text(
                            asset.owner!.email!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                DataCell(Text(_formatType(asset.assetType))),

                DataCell(
                  Text(_formatValue(asset.estimatedValue, asset.currency)),
                ),

                DataCell(AssetStatusBadge(status: asset.status)),

                DataCell(Text('${asset.reviewSummary?.reviewCount ?? 0}')),

                DataCell(
                  IconButton(
                    tooltip: 'View asset',
                    onPressed: () {
                      context.go('/assets/${asset.id}');
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatType(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String _formatValue(double? value, String currency) {
    if (value == null) {
      return '—';
    }

    return '$currency ${value.toStringAsFixed(2)}';
  }
}
