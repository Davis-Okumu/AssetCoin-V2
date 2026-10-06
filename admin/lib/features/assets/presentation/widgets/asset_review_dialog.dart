import 'package:flutter/material.dart';

class AssetReviewDialog extends StatefulWidget {
  const AssetReviewDialog({super.key, required this.onSubmit});

  final Future<void> Function(String decision, String? comments) onSubmit;

  @override
  State<AssetReviewDialog> createState() => _AssetReviewDialogState();
}

class _AssetReviewDialogState extends State<AssetReviewDialog> {
  String? _decision;

  final TextEditingController _commentsController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  String _decisionLabel(String value) {
    switch (value) {
      case 'under_review':
        return 'Move to Under Review';

      case 'changes_required':
        return 'Request Changes';

      case 'approved':
        return 'Approve Asset';

      case 'rejected':
        return 'Reject Asset';

      default:
        return value;
    }
  }

  Future<void> _submit() async {
    if (_decision == null) {
      return;
    }

    final comments = _commentsController.text.trim();

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onSubmit(_decision!, comments.isEmpty ? null : comments);

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
    return AlertDialog(
      title: const Text('Review Asset'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select the review decision for this asset.'),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: _decision,
              decoration: const InputDecoration(
                labelText: 'Decision',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'under_review',
                  child: Text('Under Review'),
                ),
                DropdownMenuItem(
                  value: 'changes_required',
                  child: Text('Request Changes'),
                ),
                DropdownMenuItem(value: 'approved', child: Text('Approve')),
                DropdownMenuItem(value: 'rejected', child: Text('Reject')),
              ],
              onChanged: _submitting
                  ? null
                  : (value) {
                      setState(() {
                        _decision = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _commentsController,
              enabled: !_submitting,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Comments',
                hintText: 'Add review notes or explain your decision...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            if (_decision != null) ...[
              const SizedBox(height: 12),
              Text(
                _decisionLabel(_decision!),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
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
          onPressed: _submitting || _decision == null ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Review'),
        ),
      ],
    );
  }
}
