
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class AccountActionTile extends StatelessWidget {
  const AccountActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.isEnabled = true,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isEnabled;
  final Widget? trailing;

  Color get _iconColor {
    if (isDestructive) {
      return const Color(0xFFDC3545);
    }

    return const Color(0xFF2878D0);
  }

  Color get _iconBackground {
    if (isDestructive) {
      return const Color(0xFFFFF0F1);
    }

    return const Color(0xFFEAF3FF);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE7ECF3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _iconBackground,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: _iconColor,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDestructive
                              ? const Color(0xFFDC3545)
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                trailing ??
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDestructive
                          ? const Color(0xFFDC3545)
                          : Colors.grey.shade400,
                      size: 15,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}