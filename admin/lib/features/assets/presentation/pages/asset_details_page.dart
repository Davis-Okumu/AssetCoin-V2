import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/asset_details_controller.dart';
import '../widgets/asset_details_panel.dart';
import '../widgets/asset_review_dialog.dart';
import '../widgets/asset_status_dialog.dart';

class AssetDetailsPage extends ConsumerWidget {
  const AssetDetailsPage({super.key, required this.assetId});

  final int assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsync = ref.watch(assetDetailsControllerProvider(assetId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: assetAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, ref, error),
          data: (data) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, data),

                  const SizedBox(height: 24),

                  AssetDetailsPanel(data: data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic data) {
    final asset = data.asset;

    return Row(
      children: [
        IconButton(
          tooltip: 'Back to assets',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/assets');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asset Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(
                asset.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        OutlinedButton.icon(
          onPressed: () {
            ref
                .read(assetDetailsControllerProvider(assetId).notifier)
                .refresh();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),

        const SizedBox(width: 10),

        FilledButton.icon(
          onPressed: () {
            _showReviewDialog(context, ref);
          },
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Review'),
        ),

        const SizedBox(width: 10),

        PopupMenuButton<String>(
          tooltip: 'More actions',
          onSelected: (value) {
            if (value == 'status') {
              _showStatusDialog(context, ref, asset.status);
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(Icons.admin_panel_settings_outlined),
                  title: Text('Change Status'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Future<void> _showReviewDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AssetReviewDialog(
          onSubmit: (decision, comments) async {
            await ref
                .read(assetDetailsControllerProvider(assetId).notifier)
                .review(decision: decision, comments: comments);
          },
        );
      },
    );
  }

  Future<void> _showStatusDialog(
    BuildContext context,
    WidgetRef ref,
    String currentStatus,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AssetStatusDialog(
          currentStatus: currentStatus,
          onSubmit: (status, reason) async {
            await ref
                .read(assetDetailsControllerProvider(assetId).notifier)
                .changeStatus(status: status, reason: reason);
          },
        );
      },
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 54),
            const SizedBox(height: 14),
            const Text(
              'Unable to load asset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    context.go('/assets');
                  },
                  child: const Text('Back to Assets'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(assetDetailsControllerProvider(assetId).notifier)
                        .refresh();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
