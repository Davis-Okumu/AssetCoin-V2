import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/token_offering_model.dart';
import '../controllers/tokenization_controller.dart';
import '../controllers/tokenization_offering_controller.dart';
import '../widgets/tokenization_status_badge.dart';

// ============================================================
// OFFERING DETAIL PROVIDER (loads the offering)
// ============================================================
// NOTE: assumes tokenizationApiProvider exposes getOffering(int)
// returning Map<String, dynamic>, and that TokenOfferingModel has
// a fromJson factory. Rename if yours differ.

final tokenizationOfferingDetailProvider =
    FutureProvider.family<TokenOfferingModel, int>((ref, id) async {
      final api = ref.read(tokenizationApiProvider);

      final json = await api.getOffering(id);

      return TokenOfferingModel.fromJson(json);
    });

class TokenOfferingPage extends ConsumerWidget {
  const TokenOfferingPage({super.key, required this.offeringId});

  final int offeringId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tokenizationOfferingDetailProvider(offeringId));

    return Scaffold(
      appBar: AppBar(title: const Text('Token Offering')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(
                      tokenizationOfferingDetailProvider(offeringId),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (offering) {
          return _OfferingContent(offering: offering, offeringId: offeringId);
        },
      ),
    );
  }
}

class _OfferingContent extends ConsumerWidget {
  const _OfferingContent({required this.offering, required this.offeringId});

  final TokenOfferingModel offering;
  final int offeringId;

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    await action();

    final actionState = ref.read(tokenizationOfferingControllerProvider);

    if (actionState.hasError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: ${actionState.error}')),
        );
      }
      return;
    }

    ref.invalidate(tokenizationOfferingDetailProvider(offeringId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      tokenizationOfferingControllerProvider.notifier,
    );
    final isBusy = ref.watch(tokenizationOfferingControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(offering: offering),
              const SizedBox(height: 20),
              _DetailsCard(offering: offering),
              const SizedBox(height: 20),
              _Actions(
                offering: offering,
                isBusy: isBusy,
                onActivate: () => _runAction(
                  context,
                  ref,
                  () => controller.activate(offeringId),
                ),
                onPause: () => _runAction(
                  context,
                  ref,
                  () => controller.pause(offeringId),
                ),
                onSuspend: () => _runAction(
                  context,
                  ref,
                  () => controller.suspend(offeringId),
                ),
                onResume: () => _runAction(
                  context,
                  ref,
                  () => controller.resume(offeringId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.offering});

  final TokenOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, child: Icon(Icons.token_outlined)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering.offeringReference,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(offering.tokenName ?? 'Token Offering'),
                ],
              ),
            ),
            TokenizationStatusBadge(status: offering.status),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.offering});

  final TokenOfferingModel offering;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 48,
          runSpacing: 24,
          children: [
            _Metric(
              label: 'Offering Supply',
              value: offering.offeringSupply.toString(),
            ),
            _Metric(
              label: 'Tokens Sold',
              value: offering.tokensSold.toString(),
            ),
            _Metric(
              label: 'Price',
              value: '${offering.pricePerToken} ${offering.currency}',
            ),
            _Metric(
              label: 'Minimum Purchase',
              value: offering.minimumPurchaseQuantity.toString(),
            ),
            _Metric(
              label: 'Maximum Purchase',
              value: offering.maximumPurchaseQuantity.toString(),
            ),
            _Metric(
              label: 'Total Raised',
              value: '${offering.totalRaised} ${offering.currency}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.offering,
    required this.isBusy,
    required this.onActivate,
    required this.onPause,
    required this.onSuspend,
    required this.onResume,
  });

  final TokenOfferingModel offering;
  final bool isBusy;
  final Future<void> Function() onActivate;
  final Future<void> Function() onPause;
  final Future<void> Function() onSuspend;
  final Future<void> Function() onResume;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    switch (offering.status) {
      case 'draft':
      case 'scheduled':
        buttons.add(
          FilledButton.icon(
            onPressed: isBusy ? null : onActivate,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Activate'),
          ),
        );
        break;

      case 'active':
        buttons.add(
          OutlinedButton.icon(
            onPressed: isBusy ? null : onPause,
            icon: const Icon(Icons.pause_outlined),
            label: const Text('Pause'),
          ),
        );

        buttons.add(
          OutlinedButton.icon(
            onPressed: isBusy ? null : onSuspend,
            icon: const Icon(Icons.block_outlined),
            label: const Text('Suspend'),
          ),
        );
        break;

      case 'paused':
      case 'suspended':
        buttons.add(
          FilledButton.icon(
            onPressed: isBusy ? null : onResume,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Resume'),
          ),
        );
        break;
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(spacing: 12, runSpacing: 12, children: buttons),
      ),
    );
  }
}
