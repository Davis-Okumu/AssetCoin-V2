import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/finance_reconciliation_model.dart';
import '../controllers/finance_overview_controller.dart';
import '../widgets/finance_back_button.dart';
import '../widgets/finance_empty_state.dart';
import '../widgets/finance_status_badge.dart';

final financeReconciliationProvider =
    FutureProvider.autoDispose<List<FinanceReconciliationModel>>((ref) async {
      final repository = ref.read(adminFinanceRepositoryProvider);
      return repository.getReconciliation();
    });

class FinanceReconciliationPage extends ConsumerWidget {
  const FinanceReconciliationPage({super.key});

  String _money(num? amount, String currency) {
    if (amount == null) return '—';
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  Color? _differenceColor(BuildContext context, num? difference) {
    if (difference == null) return null;
    return difference == 0 ? Colors.green : Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(financeReconciliationProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FinanceBackButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Financial Reconciliation',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh reconciliation records',
                  onPressed: () =>
                      ref.invalidate(financeReconciliationProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Inspect reconciliation records and differences reported by the backend.',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: reconciliation.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => FinanceEmptyState(
                  title: 'Unable to load reconciliation records',
                  message: error.toString(),
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(financeReconciliationProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const FinanceEmptyState(
                      title: 'No reconciliation records',
                      message: 'The backend has not returned any reconciliation records.',
                      icon: Icons.fact_check_outlined,
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 850),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Reference')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Expected')),
                            DataColumn(label: Text('Actual')),
                            DataColumn(label: Text('Difference')),
                          ],
                          rows: items.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(SelectableText(item.reference)),
                                DataCell(
                                  FinanceStatusBadge(status: item.status),
                                ),
                                DataCell(
                                  Text(
                                    _money(item.expectedAmount, item.currency),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _money(item.actualAmount, item.currency),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _money(item.difference, item.currency),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _differenceColor(
                                        context,
                                        item.difference,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
