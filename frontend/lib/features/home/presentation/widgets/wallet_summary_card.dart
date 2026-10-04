
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/wallet_summary.dart';

class WalletSummaryCard extends StatelessWidget {
  final WalletSummary summary;

  const WalletSummaryCard({
    super.key,
    required this.summary,
  });

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Asset Value',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${summary.currency} ${_formatAmount(summary.totalAssetValue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 22),

          const Divider(
            color: Colors.white30,
            height: 1,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  title: 'Fiat Balance',
                  value: summary.fiatBalance,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildBalanceItem(
                  title: 'Token Balance',
                  value: summary.tokenBalance,
                  isToken: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildBalanceItem(
            title: 'Token Value',
            value: summary.tokenValue,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required String title,
    required double value,
    bool isToken = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          isToken
              ? '${_formatAmount(value)} tokens'
              : '${summary.currency} ${_formatAmount(value)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}