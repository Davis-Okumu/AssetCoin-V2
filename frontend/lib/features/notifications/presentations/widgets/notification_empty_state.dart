import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class NotificationEmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onClearFilters;

  const NotificationEmptyState({
    super.key,
    this.title,
    this.message,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'No notifications yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message ??
                  'You are all caught up. We will notify you when something important happens.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (onClearFilters != null) ...[
              const SizedBox(height: 22),
              TextButton(
                onPressed: onClearFilters,
                child: const Text(
                  'Clear filters',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}