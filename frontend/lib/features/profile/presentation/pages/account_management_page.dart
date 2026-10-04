
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../widgets/account_status_card.dart';
import '../widgets/account_action_tile.dart';
import '../widgets/account_closure_dialog.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() =>
      _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  // These values are placeholders until the account management
  // endpoints are connected to the backend.
  final String _accountStatus = 'Active';
  final String _lastUpdated = '03 October 2026';

  bool _isProcessing = false;

  Future<void> _showInformationDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestDataDownload() async {
    await _showInformationDialog(
      title: 'Download My Data',
      message:
          'Your data export request will be available here once the '
          'account data export service has been connected.\n\n'
          'The export will allow you to request a copy of the personal '
          'information and account activity associated with your '
          'AssetCoin account.',
    );
  }

  Future<void> _showDeactivateDialog() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Temporarily deactivate account?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Temporarily deactivating your account may restrict your '
            'ability to sign in and use certain AssetCoin services.\n\n'
            'Before deactivation, any pending transactions, outstanding '
            'balances, asset submissions and token holdings must be '
            'reviewed.\n\n'
            'This action is not connected to the backend yet. No changes '
            'will be made to your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _showInformationDialog(
        title: 'Not available yet',
        message:
            'Account deactivation has not been connected to the '
            'AssetCoin backend. Your account remains active.',
      );
    }
  }

  Future<void> _requestAccountClosure() async {
    if (_isProcessing) return;

    final confirmed = await AccountClosureDialog.show(context);

    if (confirmed != true || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _showInformationDialog(
        title: 'Closure request not submitted',
        message:
            'The account closure request feature is not connected to '
            'the backend yet.\n\n'
            'Your account remains active. No closure request has been '
            'submitted and no account information has been deleted.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotice({
    required IconData icon,
    required String message,
    Color? color,
  }) {
    final noticeColor = color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: noticeColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: noticeColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: noticeColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Account Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage your AssetCoin account, review its status, '
                'and control important account-related requests.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 22),

              _buildSectionHeading(
                title: 'Account Overview',
                subtitle:
                    'Your current account status and activity information.',
              ),

              const SizedBox(height: 12),

              AccountStatusCard(
                status: _accountStatus,
                description:
                    'Your AssetCoin account is currently active. '
                    'You can access the services available to your account.',
                lastUpdated: _lastUpdated,
              ),

              const SizedBox(height: 28),

              _buildSectionHeading(
                title: 'Your Account Data',
                subtitle:
                    'Request a copy of the information associated '
                    'with your AssetCoin account.',
              ),

              const SizedBox(height: 12),

              AccountActionTile(
                title: 'Download My Data',
                subtitle:
                    'Request a copy of your personal information '
                    'and account activity.',
                icon: Icons.download_outlined,
                onTap: _requestDataDownload,
              ),

              const SizedBox(height: 28),

              _buildSectionHeading(
                title: 'Account Access',
                subtitle:
                    'Manage the availability of your AssetCoin account.',
              ),

              const SizedBox(height: 12),

              AccountActionTile(
                title: 'Temporarily Deactivate Account',
                subtitle:
                    'Request a temporary restriction of access '
                    'to your account.',
                icon: Icons.pause_circle_outline_rounded,
                onTap: _showDeactivateDialog,
              ),

              const SizedBox(height: 28),

              _buildSectionHeading(
                title: 'Account Closure',
                subtitle:
                    'Review the implications before requesting '
                    'permanent account closure.',
              ),

              const SizedBox(height: 12),

              AccountActionTile(
                title: 'Request Account Closure',
                subtitle:
                    'Start a request to close your AssetCoin account.',
                icon: Icons.person_remove_alt_1_outlined,
                isDestructive: true,
                isEnabled: !_isProcessing,
                onTap: _requestAccountClosure,
                trailing: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 16),

              _buildNotice(
                icon: Icons.info_outline_rounded,
                message:
                    'Account data export, deactivation and closure '
                    'requests are not connected to the backend yet. '
                    'Using these options will not change your account.',
              ),

              const SizedBox(height: 12),

              _buildNotice(
                icon: Icons.security_rounded,
                color: Colors.orange.shade800,
                message:
                    'AssetCoin must retain required financial, '
                    'transaction, ownership and audit records in '
                    'accordance with applicable requirements. '
                    'Closing an account does not necessarily mean '
                    'all associated records can be erased.',
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'AssetCoin Account Management',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}