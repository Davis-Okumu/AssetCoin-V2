
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class AccountClosureDialog extends StatefulWidget {
  const AccountClosureDialog({
    super.key,
  });

  /// Displays the account closure confirmation dialog.
  ///
  /// Returns true when the user confirms the request.
  /// Returns false or null when the user cancels.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AccountClosureDialog(),
    );
  }

  @override
  State<AccountClosureDialog> createState() =>
      _AccountClosureDialogState();
}

class _AccountClosureDialogState extends State<AccountClosureDialog> {
  final TextEditingController _confirmationController =
      TextEditingController();

  bool _acknowledged = false;

  bool get _canConfirm {
    return _acknowledged &&
        _confirmationController.text.trim().toUpperCase() == 'CLOSE';
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _confirmRequest() {
    if (!_canConfirm) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
      contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),

      title: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_remove_outlined,
              color: Color(0xFFDC3545),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Request Account Closure',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),

      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to request closure of your '
              'AssetCoin account?',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            _buildWarningItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Outstanding balances',
              description:
                  'Review your wallet balances and any pending '
                  'transactions before requesting closure.',
            ),

            const SizedBox(height: 13),

            _buildWarningItem(
              icon: Icons.token_outlined,
              title: 'Assets and token holdings',
              description:
                  'Any assets, listings or token holdings associated '
                  'with your account may require review and resolution.',
            ),

            const SizedBox(height: 13),

            _buildWarningItem(
              icon: Icons.receipt_long_outlined,
              title: 'Financial records',
              description:
                  'Transaction history, ownership records and ledger '
                  'entries may need to be retained for legal, audit '
                  'and regulatory purposes.',
            ),

            const SizedBox(height: 13),

            _buildWarningItem(
              icon: Icons.verified_user_outlined,
              title: 'Verification and review',
              description:
                  'Your closure request may require identity '
                  'verification and approval before it is processed.',
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFE2A6),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB7791F),
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This action starts an account closure request. '
                      'It does not immediately delete your account '
                      'or permanently erase your records.',
                      style: TextStyle(
                        color: Color(0xFF805B1B),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            CheckboxListTile(
              value: _acknowledged,
              onChanged: (value) {
                setState(() {
                  _acknowledged = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF2878D0),
              title: const Text(
                'I understand the account closure conditions.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Type CLOSE to confirm:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _confirmationController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Enter CLOSE',
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(
                    color: Color(0xFFE1E7EF),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(
                    color: Color(0xFFE1E7EF),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(
                    color: Color(0xFF2878D0),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF526176),
            side: const BorderSide(
              color: Color(0xFFE1E7EF),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _canConfirm ? _confirmRequest : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC3545),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2878D0),
            size: 19,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}