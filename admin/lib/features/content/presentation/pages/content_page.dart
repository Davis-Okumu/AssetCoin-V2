import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_content_model.dart';
import '../controllers/admin_content_controller.dart';
import '../widgets/content_editor_dialog.dart';
import '../widgets/content_filter_bar.dart';
import '../widgets/content_overview_cards.dart';
import '../widgets/content_table.dart';

class ContentPage extends ConsumerWidget {
  const ContentPage({super.key});

  static const Color _blue = Color(0xFF1746A2);
  static const Color _red = Color(0xFFE53945);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(adminContentControllerProvider);

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _ErrorView(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(adminContentControllerProvider);
        },
      ),
      data: (contentState) {
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(adminContentControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _PageHeader(
                onCreate: () =>
                    _openEditor(context, ref, type: contentState.type),
              ),
              const SizedBox(height: 24),

              ContentOverviewCards(overview: contentState.overview),
              const SizedBox(height: 28),

              _SectionHeading(
                title: 'Content library',
                subtitle:
                    'Select a content type to view and manage its records.',
              ),
              const SizedBox(height: 16),

              _ContentTypeSelector(
                selectedType: contentState.type,
                onChanged: (type) {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .loadContent(
                        type: type,
                        clearStatus: true,
                        clearCategory: true,
                        search: '',
                        page: 1,
                      );
                },
              ),
              const SizedBox(height: 18),

              ContentFilterBar(
                type: contentState.type,
                status: contentState.status,
                category: contentState.category,
                search: contentState.search,
                onStatusChanged: (status) {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .loadContent(
                        status: status,
                        clearStatus: status == null,
                        page: 1,
                      );
                },
                onCategoryChanged: (category) {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .loadContent(
                        category: category,
                        clearCategory: category == null,
                        page: 1,
                      );
                },
                onSearchChanged: (search) {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .loadContent(search: search, page: 1);
                },
                onRefresh: () {
                  ref.read(adminContentControllerProvider.notifier).refresh();
                },
                onReset: () {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .loadContent(
                        status: null,
                        category: null,
                        search: '',
                        page: 1,
                        clearStatus: true,
                        clearCategory: true,
                      );
                },
              ),
              const SizedBox(height: 18),

              ContentTable(
                type: contentState.type,
                items: contentState.items,
                total: contentState.total,
                page: contentState.page,
                limit: contentState.limit,
                totalPages: contentState.totalPages,
                onEdit: (item) => _openEditor(
                  context,
                  ref,
                  type: contentState.type,
                  item: item,
                ),
                onPublish: (item) => _confirmAction(
                  context,
                  title: 'Publish content?',
                  message:
                      'Publish "${item.title}" so it can be shown to customers?',
                  confirmLabel: 'Publish',
                  onConfirm: () async {
                    await ref
                        .read(adminContentControllerProvider.notifier)
                        .publishContent(type: item.type, id: item.id);
                  },
                ),
                onArchive: (item) => _confirmAction(
                  context,
                  title: 'Archive content?',
                  message:
                      'Archive "${item.title}"? It will no longer be treated as published content.',
                  confirmLabel: 'Archive',
                  onConfirm: () async {
                    await ref
                        .read(adminContentControllerProvider.notifier)
                        .archiveContent(type: item.type, id: item.id);
                  },
                ),
                onDelete: (item) => _confirmAction(
                  context,
                  title: 'Delete content?',
                  message:
                      'Permanently delete "${item.title}"? This action cannot be undone.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                  onConfirm: () async {
                    await ref
                        .read(adminContentControllerProvider.notifier)
                        .deleteContent(type: item.type, id: item.id);
                  },
                ),
                onNextPage: () {
                  ref.read(adminContentControllerProvider.notifier).nextPage();
                },
                onPreviousPage: () {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .previousPage();
                },
                onPageSizeChanged: (limit) {
                  ref
                      .read(adminContentControllerProvider.notifier)
                      .changePageSize(limit);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CONTENT EDITOR
  // ============================================================

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    required String type,
    AdminContentModel? item,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContentEditorDialog(type: type, item: item),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item == null
                ? 'Content created successfully.'
                : 'Content updated successfully.',
          ),
          backgroundColor: _blue,
        ),
      );
    }
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive ? _red : _blue,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await onConfirm();

      if (!context.mounted) return;

      final successMessage = switch (confirmLabel) {
        'Publish' => 'Content published successfully.',
        'Archive' => 'Content archived successfully.',
        'Delete' => 'Content deleted successfully.',
        _ => 'Action completed successfully.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: _blue),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $error'), backgroundColor: _red),
      );
    }
  }
}

// ================================================================
// PAGE HEADER
// ================================================================

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your content',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              'Publish clear, accurate information for AssetCoin customers.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Create content'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE53945),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SECTION HEADING
// ================================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
        ),
      ],
    );
  }
}

// ================================================================
// CONTENT TYPE SELECTOR
// ================================================================

class _ContentTypeSelector extends StatelessWidget {
  const _ContentTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  static const _types = [
    (
      value: 'announcements',
      label: 'Announcements',
      icon: Icons.campaign_outlined,
    ),
    (value: 'news', label: 'News & Articles', icon: Icons.article_outlined),
    (
      value: 'publications',
      label: 'Publications',
      icon: Icons.menu_book_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _types.map((type) {
          final selected = selectedType == type.value;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              selected: selected,
              avatar: Icon(
                type.icon,
                size: 18,
                color: selected ? Colors.white : const Color(0xFF1746A2),
              ),
              label: Text(type.label),
              selectedColor: const Color(0xFF1746A2),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF263238),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF1746A2)
                    : const Color(0xFFE0E5EC),
              ),
              onSelected: (_) => onChanged(type.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ================================================================
// ERROR VIEW
// ================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 54,
                color: Color(0xFFE53945),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load content',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
