import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../models/app_models.dart';
import '../widgets/app_widgets.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  Future<void> _addMedication(BuildContext context) async {
    final entry = await showDialog<MedicationEntry>(
      context: context,
      builder: (_) => const _MedicationDialog(),
    );
    if (entry != null && context.mounted) {
      AppScope.of(context).addMedication(entry);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder added to this session.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final entries = app.medications;
    return Scaffold(
      appBar: AppBar(title: const Text('Medication manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMedication(context),
        icon: const Icon(Icons.add),
        label: const Text('Add reminder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DemoDataNotice(),
          const SizedBox(height: 16),
          const Text(
            'Your reminder list',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF102A43),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Entries are stored in memory in this prototype. They are not '
            'saved after the app closes and do not trigger phone alarms.',
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const EmptyState(
              icon: Icons.medication_outlined,
              title: 'No reminders yet',
              message: 'Add a reminder to see it in this list.',
            )
          else
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: entry.isCompleted,
                        onChanged: (value) =>
                            app.toggleMedication(entry.id, value ?? false),
                        title: Text(
                          entry.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          entry.notes.isEmpty
                              ? entry.schedule
                              : '${entry.schedule}\n${entry.notes}',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmDelete(context, entry),
                          icon: const Icon(Icons.delete_outline, size: 17),
                          label: const Text('Remove'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 14),
          const Text(
            'Use reminders only to organise instructions already provided by '
            'a qualified healthcare professional. CaringMate does not '
            'recommend medicines or doses.',
            style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MedicationEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove reminder?'),
        content: Text('Remove "${entry.name}" from this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      AppScope.of(context).removeMedication(entry.id);
    }
  }
}

class _MedicationDialog extends StatefulWidget {
  const _MedicationDialog();

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _scheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      MedicationEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        schedule: _scheduleController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a reminder'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Reminder name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name';
                  }
                  if (value.trim().length > 60)
                    return 'Use 60 characters or less';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _scheduleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Schedule description',
                  hintText: 'For example, as instructed by your clinician',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the schedule';
                  }
                  if (value.trim().length > 80)
                    return 'Use 80 characters or less';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'Use 200 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'This creates an in-app list item only. It does not schedule '
                'an operating-system notification.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
