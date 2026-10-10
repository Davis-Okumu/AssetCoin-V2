import 'package:flutter/material.dart';

import '../../data/models/admin_ledger_entry_model.dart';
import 'ledger_hash_inspection_panel.dart';

class LedgerEntryDetailsPanel extends StatelessWidget {
  const LedgerEntryDetailsPanel({
    super.key,
    required this.entry,
    required this.onInspectHashes,
    this.hashInspection,
    this.isLoadingHashInspection = false,
    this.hashInspectionError,
  });

  final AdminLedgerEntryModel entry;
  final VoidCallback onInspectHashes;
  final Map<String, dynamic>? hashInspection;
  final bool isLoadingHashInspection;
  final String? hashInspectionError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ledger entry #${entry.id}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusPill(
                      label: entry.entryTypeLabel,
                      color: entry.isCredit
                          ? const Color(0xFF16803D)
                          : const Color(0xFFDC2626),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SelectableText(
                  entry.entryReference.isEmpty
                      ? 'No entry reference'
                      : entry.entryReference,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Entry information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow('Amount', '${entry.amount} ${entry.currency}'),
                _DetailRow('Entry type', entry.entryTypeLabel),
                _DetailRow('Asset type', entry.assetTypeLabel),
                _DetailRow('Customer', _orDash(entry.customerName)),
                _DetailRow('User ID', _orDash(entry.userId)),
                _DetailRow('Wallet ID', _orDash(entry.walletId)),
                _DetailRow('Wallet address', _orDash(entry.walletAddress)),
                _DetailRow('Token ID', _orDash(entry.tokenId)),
                _DetailRow('Transaction ID', _orDash(entry.transactionId)),
                _DetailRow('Balance before', _orDash(entry.balanceBefore)),
                _DetailRow('Balance after', _orDash(entry.balanceAfter)),
                _DetailRow('Created at', _formatDate(entry.createdAt)),
                const SizedBox(height: 18),
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(_orDash(entry.description)),
                const SizedBox(height: 18),
                Text(
                  'Linked marketplace transaction',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  'Reference',
                  _orDash(entry.marketplaceTransactionReference),
                ),
                _DetailRow(
                  'Status',
                  _orDash(entry.marketplaceTransactionStatus),
                ),
                _DetailRow(
                  'Quantity',
                  _orDash(entry.marketplaceTransactionQuantity),
                ),
                _DetailRow(
                  'Price per token',
                  _orDash(entry.marketplacePricePerToken),
                ),
                _DetailRow(
                  'Total amount',
                  _orDash(entry.marketplaceTotalAmount),
                ),
                _DetailRow('Fee amount', _orDash(entry.marketplaceFeeAmount)),
                const SizedBox(height: 18),
                Text(
                  'Stored hash fields',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  'Previous hash',
                  _orDash(entry.previousHash),
                  selectable: true,
                ),
                _DetailRow(
                  'Entry hash',
                  _orDash(entry.entryHash),
                  selectable: true,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: isLoadingHashInspection ? null : onInspectHashes,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(
                      isLoadingHashInspection
                          ? 'Inspecting...'
                          : 'Inspect stored hashes',
                    ),
                  ),
                ),
                if (isLoadingHashInspection) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
                if (hashInspectionError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    hashInspectionError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          if (hashInspection != null) ...[
            const SizedBox(height: 16),
            LedgerHashInspectionPanel(inspection: hashInspection!),
          ],
        ],
      ),
    );
  }

  String _orDash(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final value = date.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');

    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.selectable = false});

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 175,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: selectable ? SelectableText(value) : Text(value)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
