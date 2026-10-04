
import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final normalized =
        status.trim().toLowerCase();

    final configuration = _configurationFor(
      normalized,
      colorScheme,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: configuration.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            configuration.icon,
            size: compact ? 13 : 15,
            color: configuration.foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            _formatStatus(normalized),
            style: theme.textTheme.labelMedium?.copyWith(
              color: configuration.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfiguration _configurationFor(
    String status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case 'filled':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.primaryContainer,
          foregroundColor:
              colorScheme.onPrimaryContainer,
          icon: Icons.check_circle_outline,
        );

      case 'partially_filled':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.secondaryContainer,
          foregroundColor:
              colorScheme.onSecondaryContainer,
          icon: Icons.timelapse_rounded,
        );

      case 'pending':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.tertiaryContainer,
          foregroundColor:
              colorScheme.onTertiaryContainer,
          icon: Icons.schedule_outlined,
        );

      case 'open':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.secondaryContainer,
          foregroundColor:
              colorScheme.onSecondaryContainer,
          icon: Icons.radio_button_checked,
        );

      case 'cancelled':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.errorContainer,
          foregroundColor:
              colorScheme.onErrorContainer,
          icon: Icons.cancel_outlined,
        );

      case 'rejected':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.errorContainer,
          foregroundColor:
              colorScheme.onErrorContainer,
          icon: Icons.block_outlined,
        );

      case 'expired':
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.surfaceContainerHighest,
          foregroundColor:
              colorScheme.onSurfaceVariant,
          icon: Icons.timer_off_outlined,
        );

      default:
        return _StatusConfiguration(
          backgroundColor:
              colorScheme.surfaceContainerHighest,
          foregroundColor:
              colorScheme.onSurfaceVariant,
          icon: Icons.info_outline,
        );
    }
  }

  String _formatStatus(String value) {
    if (value.isEmpty) {
      return 'Unknown';
    }

    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}'
                  '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _StatusConfiguration {
  const _StatusConfiguration({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
}

