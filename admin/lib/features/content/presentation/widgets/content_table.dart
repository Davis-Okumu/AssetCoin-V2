import 'package:flutter/material.dart';

import '../../data/models/admin_content_model.dart';

class ContentTable extends StatelessWidget {
  const ContentTable({
    super.key,
    required this.items,
    required this.type,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.onEdit,
    required this.onPublish,
    required this.onArchive,
    required this.onDelete,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSizeChanged,
  });

  final List<AdminContentModel> items;
  final String type;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  final ValueChanged<AdminContentModel> onEdit;
  final ValueChanged<AdminContentModel> onPublish;
  final ValueChanged<AdminContentModel> onArchive;
  final ValueChanged<AdminContentModel> onDelete;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onPageSizeChanged;

  static const Color _primaryRed = Color(0xFFD32F2F);
  static const Color _primaryBlue = Color(0xFF1565C0);
  static const Color _textColor = Color(0xFF202B3C);
  static const Color _mutedColor = Color(0xFF758195);
  static const Color _borderColor = Color(0xFFE8ECF2);

  @override
  Widget build(BuildContext context) {
    final start = total == 0 ? 0 : ((page - 1) * limit) + 1;
    final end = total == 0 ? 0 : (start + items.length - 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1, color: _borderColor),
          if (items.isEmpty)
            const _EmptyContentState()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 54,
                dataRowMinHeight: 76,
                dataRowMaxHeight: 92,
                horizontalMargin: 20,
                columnSpacing: 28,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                dividerThickness: 0.7,
                columns: const [
                  DataColumn(label: Text('CONTENT')),
                  DataColumn(label: Text('CATEGORY')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('CREATED')),
                  DataColumn(label: Text('PUBLISHED')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: items.map(_buildRow).toList(),
              ),
            ),
          const Divider(height: 1, color: _borderColor),
          _buildPagination(context, start, end),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sectionTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$total ${total == 1 ? 'record' : 'records'} found',
                  style: const TextStyle(fontSize: 12, color: _mutedColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined, size: 17, color: _primaryBlue),
                const SizedBox(width: 7),
                Text(
                  _typeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(AdminContentModel item) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 270,
            child: Row(
              children: [
                _ContentThumbnail(imageUrl: item.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      if ((item.summary ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.summary!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _mutedColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(
            item.categoryDisplayName,
            style: const TextStyle(fontSize: 12, color: _textColor),
          ),
        ),
        DataCell(_StatusBadge(status: item.status)),
        DataCell(
          Text(
            _formatDate(item.createdAt),
            style: const TextStyle(fontSize: 12, color: _mutedColor),
          ),
        ),
        DataCell(
          Text(
            _formatDate(item.publishedAt),
            style: const TextStyle(fontSize: 12, color: _mutedColor),
          ),
        ),
        DataCell(_buildActions(item)),
      ],
    );
  }

  Widget _buildActions(AdminContentModel item) {
    return PopupMenuButton<String>(
      tooltip: 'Content actions',
      icon: const Icon(Icons.more_horiz, color: _mutedColor),
      onSelected: (action) {
        switch (action) {
          case 'edit':
            onEdit(item);
          case 'publish':
            onPublish(item);
          case 'archive':
            onArchive(item);
          case 'delete':
            onDelete(item);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: _ActionMenuItem(icon: Icons.edit_outlined, label: 'Edit'),
        ),
        if (item.status == 'draft')
          const PopupMenuItem(
            value: 'publish',
            child: _ActionMenuItem(
              icon: Icons.publish_outlined,
              label: 'Publish',
              color: _primaryBlue,
            ),
          ),
        if (item.status == 'published')
          const PopupMenuItem(
            value: 'archive',
            child: _ActionMenuItem(
              icon: Icons.archive_outlined,
              label: 'Archive',
              color: Color(0xFFEF6C00),
            ),
          ),
        if (item.status == 'archived')
          const PopupMenuItem(
            value: 'publish',
            child: _ActionMenuItem(
              icon: Icons.publish_outlined,
              label: 'Publish again',
              color: _primaryBlue,
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _ActionMenuItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: _primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, int start, int end) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Text(
            'Showing $start–$end of $total',
            style: const TextStyle(fontSize: 12, color: _mutedColor),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rows:',
                style: TextStyle(fontSize: 12, color: _mutedColor),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: limit,
                underline: const SizedBox.shrink(),
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
                onPressed: page > 1 ? onPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '$page of ${totalPages < 1 ? 1 : totalPages}',
                style: const TextStyle(
                  fontSize: 12,
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: page < totalPages ? onNextPage : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _sectionTitle {
    switch (type) {
      case 'announcements':
        return 'Announcements';
      case 'news':
        return 'News & Articles';
      case 'publications':
        return 'Publications';
      default:
        return 'Content Records';
    }
  }

  String get _typeLabel {
    switch (type) {
      case 'announcements':
        return 'Announcements';
      case 'news':
        return 'News';
      case 'publications':
        return 'Publications';
      default:
        return 'Content';
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }
}

class _ContentThumbnail extends StatelessWidget {
  const _ContentThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 46,
        height: 46,
        color: const Color(0xFFF0F3F8),
        child: url.isEmpty
            ? const Icon(
                Icons.image_outlined,
                color: Color(0xFF8791A2),
                size: 22,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF8791A2),
                    size: 22,
                  );
                },
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final Color color;
    final String label;
    final IconData icon;

    switch (normalized) {
      case 'published':
        color = const Color(0xFF2E7D32);
        label = 'Published';
        icon = Icons.check_circle_outline;
      case 'archived':
        color = const Color(0xFF687386);
        label = 'Archived';
        icon = Icons.archive_outlined;
      case 'draft':
        color = const Color(0xFFEF6C00);
        label = 'Draft';
        icon = Icons.edit_note_outlined;
      default:
        color = const Color(0xFF1565C0);
        label = normalized.isEmpty
            ? 'Unknown'
            : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionMenuItem extends StatelessWidget {
  const _ActionMenuItem({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? const Color(0xFF687386)),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

class _EmptyContentState extends StatelessWidget {
  const _EmptyContentState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 32,
              color: Color(0xFF8791A2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No content found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202B3C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your filters or create a new content record.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF758195)),
          ),
        ],
      ),
    );
  }
}
