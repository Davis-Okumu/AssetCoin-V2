import 'package:flutter/material.dart';

class FinanceBackButton extends StatelessWidget {
  const FinanceBackButton({super.key, this.onPressed});

  /// Optional override, e.g. for custom navigation back to the assets page.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back to assets',
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back),
    );
  }
}
