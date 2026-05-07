import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/data_provider.dart';

class StudySchedulingScreen extends ConsumerStatefulWidget {
  const StudySchedulingScreen({super.key});

  @override
  ConsumerState<StudySchedulingScreen> createState() => _StudySchedulingScreenState();
}

class _StudySchedulingScreenState extends ConsumerState<StudySchedulingScreen> {
  final _uuid = const Uuid();

  void _showAddSessionDialog() {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add subjects and topics first.')),
      );
      return;
    }

    String? selectedSubjectId = subjects.first.id;
    String? selectedTopicId = subjects.first.topics.isNotEmpty ? subjects.first.topics.first.id : null;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final durationController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final currentSubject = subjects.firstWhere((s) => s.id == selectedSubjectId);
          return AlertDialog(
            title: const Text('Schedule Session'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSubjectId,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedSubjectId = val;
                        final newSubject = subjects.firstWhere((s) => s.id == val);
                        selectedTopicId = newSubject.topics.isNotEmpty ? newSubject.topics.first.id : null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedTopicId,
                    decoration: const InputDecoration(labelText: 'Topic'),
                    items: currentSubject.topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedTopicId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setStateDialog(() => selectedDate = date);
                    },
                  ),
                  ListTile(
                    title: Text('Time: ${selectedTime.format(context)}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) setStateDialog(() => selectedTime = time);
                    },
                  ),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Duration (mins)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (selectedSubjectId != null && selectedTopicId != null) {
                    final duration = int.tryParse(durationController.text) ?? 0;
                    if (duration <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid duration (e.g. 60).')));
                      return;
                    }
                    final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                    if (dt.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot schedule a session in the past.')));
                      return;
                    }
                    ref.read(sessionsProvider.notifier).addSession(
                      StudySession(
                        id: _uuid.v4(),
                        subjectId: selectedSubjectId!,
                        topicId: selectedTopicId!,
                        dateTime: dt,
                        durationMinutes: duration,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session scheduled successfully!')));
                  }
                },
                child: const Text('Schedule'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSessionDialog,
          ),
        ],
      ),
      body: sessions.isEmpty
          ? const Center(child: Text('No sessions scheduled. Tap + to add.'))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (ctx, i) {
                final session = sessions[i];
                final subject = subjects.cast<Subject?>().firstWhere((s) => s?.id == session.subjectId, orElse: () => null);
                final topic = subject?.topics.cast<Topic?>().firstWhere((t) => t?.id == session.topicId, orElse: () => null);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${subject?.name ?? 'Unknown'} - ${topic?.name ?? 'Unknown'}'),
                    subtitle: Text('${DateFormat('MMM dd, yyyy - hh:mm a').format(session.dateTime)} • ${session.durationMinutes} mins'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(sessionsProvider.notifier).deleteSession(session.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
