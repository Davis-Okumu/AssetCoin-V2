import 'package:flutter/material.dart';

class AssetStatusDialog extends StatefulWidget {
  const AssetStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onSubmit,
  });

  final String currentStatus;

  final Future<void> Function(String status, String? reason) onSubmit;

  @override
  State<AssetStatusDialog> createState() => _AssetStatusDialogState();
}

class _AssetStatusDialogState extends State<AssetStatusDialog> {
  String? _status;

  final TextEditingController _reasonController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.currentStatus == 'suspended') {
      _status = 'approved';
    } else {
      _status = 'suspended';
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_status == null) {
      return;
    }

    final reason = _reasonController.text.trim();

    if (_status == 'suspended' && reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A reason is required when suspending an asset.'),
        ),
      );

      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onSubmit(_status!, reason.isEmpty ? null : reason);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final suspending = _status == 'suspended';

    return AlertDialog(
      title: Text(suspending ? 'Suspend Asset' : 'Restore Asset'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suspending
                  ? 'Suspending an asset will remove it from its normal active workflow.'
                  : 'This will restore the suspended asset to approved status.',
            ),

            const SizedBox(height: 18),

            if (widget.currentStatus != 'suspended')
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'New Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onChanged: _submitting
                    ? null
                    : (value) {
                        setState(() {
                          _status = value;
                        });
                      },
              ),

            const SizedBox(height: 16),

            TextField(
              controller: _reasonController,
              enabled: !_submitting,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: suspending ? 'Reason *' : 'Reason',
                hintText: suspending
                    ? 'Explain why this asset is being suspended...'
                    : 'Explain the status change...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(suspending ? 'Suspend Asset' : 'Restore Asset'),
        ),
      ],
    );
  }
}
