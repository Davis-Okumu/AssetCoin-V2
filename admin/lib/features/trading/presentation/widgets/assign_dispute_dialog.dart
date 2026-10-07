import 'package:flutter/material.dart';

Future<int?> showAssignDisputeDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Assign dispute'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Admin staff ID',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final id = int.tryParse(controller.text.trim());
            if (id != null && id > 0) Navigator.pop(context, id);
          },
          child: const Text('Assign'),
        ),
      ],
    ),
  );
}
