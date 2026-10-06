import 'package:flutter/material.dart';

import '../../data/models/admin_asset_list_model.dart';

class AssetSummaryCards extends StatelessWidget {
  const AssetSummaryCards({super.key, required this.data});

  final AdminAssetListModel data;

  int _countByStatus(String status) {
    return data.items.where((asset) => asset.status == status).length;
  }

  double _totalValue() {
    return data.items.fold<double>(
      0,
      (total, asset) => total + (asset.estimatedValue ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCardData(
        title: 'Total Assets',
        value: '${data.pagination.total}',
        icon: Icons.inventory_2_outlined,
      ),
      _SummaryCardData(
        title: 'Pending Review',
        value: '${_countByStatus('pending') + _countByStatus('under_review')}',
        icon: Icons.pending_actions_outlined,
      ),
      _SummaryCardData(
        title: 'Approved',
        value: '${_countByStatus('approved')}',
        icon: Icons.verified_outlined,
      ),
      _SummaryCardData(
        title: 'Tokenized',
        value: '${_countByStatus('tokenized')}',
        icon: Icons.token_outlined,
      ),
      _SummaryCardData(
        title: 'Page Value',
        value: _formatValue(_totalValue()),
        icon: Icons.account_balance_wallet_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1300) {
          columns = 5;
        } else if (width >= 900) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: columns == 1 ? 3.2 : 2.0,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];

            return _SummaryCard(data: card);
          },
        );
      },
    );
  }

  String _formatValue(double value) {
    if (value == 0) {
      return 'KES 0';
    }

    return 'KES ${value.toStringAsFixed(0)}';
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
