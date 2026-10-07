import 'package:flutter/material.dart';

class TradingDisputeUpdate {
  const TradingDisputeUpdate({this.status, this.priority, this.resolutionNotes});
  final String? status;
  final String? priority;
  final String? resolutionNotes;
}

Future<TradingDisputeUpdate?> showUpdateDisputeDialog(
  BuildContext context, {
  String? currentStatus,
  String? currentPriority,
}) async {
  String status = currentStatus ?? 'open';
  String priority = currentPriority ?? 'normal';
  final notes = TextEditingController();

  return showDialog<TradingDisputeUpdate>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Update dispute'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  'open','under_review','awaiting_information','resolved','rejected','closed'
                ].map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ')))).toList(),
                onChanged: (v) => setState(() => status = v ?? status),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const ['low','normal','high','critical']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => priority = v ?? priority),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notes,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Resolution notes',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              TradingDisputeUpdate(
                status: status,
                priority: priority,
                resolutionNotes: notes.text.trim().isEmpty ? null : notes.text.trim(),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
