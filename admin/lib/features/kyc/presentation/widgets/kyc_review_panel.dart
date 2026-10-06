import 'package:flutter/material.dart';

class KycReviewPanel extends StatefulWidget {
  const KycReviewPanel({
    super.key,
    this.title = 'Review',
    this.description,
    this.initialComment,
    this.submitLabel = 'Submit',
    this.cancelLabel = 'Cancel',
    this.requireComment = true,
    this.isLoading = false,
    this.onSubmit,
    this.onCancel,
  });

  final String title;
  final String? description;
  final String? initialComment;
  final String submitLabel;
  final String cancelLabel;
  final bool requireComment;
  final bool isLoading;

  final ValueChanged<String>? onSubmit;
  final VoidCallback? onCancel;

  @override
  State<KycReviewPanel> createState() => _KycReviewPanelState();
}

class _KycReviewPanelState extends State<KycReviewPanel> {
  late final TextEditingController _commentController;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    _commentController = TextEditingController(
      text: widget.initialComment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();

    if (widget.requireComment && comment.isEmpty) {
      setState(() {
        _errorText = 'Please provide a comment.';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    widget.onSubmit?.call(comment);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (widget.description != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              minLines: 4,
              maxLines: 8,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                labelText: 'Comments',
                hintText: 'Enter your review comments...',
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onCancel,
                  child: Text(widget.cancelLabel),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: widget.isLoading ? null : _submit,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.submitLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
