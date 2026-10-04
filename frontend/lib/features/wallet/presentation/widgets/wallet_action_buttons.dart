import 'package:flutter/material.dart';

class WalletActionButtons extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onConvert;

  const WalletActionButtons({
    super.key,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _WalletActionButton(
                icon: Icons.add_rounded,
                label: 'Deposit',
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                onPressed: onDeposit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WalletActionButton(
                icon: Icons.arrow_upward_rounded,
                label: 'Withdraw',
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                onPressed: onWithdraw,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _WalletActionButton(
            icon: Icons.swap_horiz_rounded,
            label: 'Convert',
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.primary,
            borderColor: theme.colorScheme.primary.withValues(
              alpha: 0.20,
            ),
            onPressed: onConvert,
          ),
        ),
      ],
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _WalletActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: foregroundColor,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}