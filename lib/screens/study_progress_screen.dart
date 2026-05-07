import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';

class StudyProgressScreen extends ConsumerWidget {
  const StudyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: subjects.isEmpty
          ? const Center(child: Text('No subjects to track.'))
          : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (ctx, i) {
                final subject = subjects[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: subject.topics.isEmpty ? 0 : subject.completionPercentage,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                          backgroundColor: Colors.grey.shade300,
                          color: subject.completionPercentage == 1.0 ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text('${(subject.completionPercentage * 100).toStringAsFixed(1)}% Completed', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        ...subject.topics.map((topic) {
                          return ListTile(
                            title: Text(topic.name),
                            subtitle: Text('Status: ${topic.status}'),
                            trailing: DropdownButton<String>(
                              value: topic.status,
                              items: ['Not Started', 'In Progress', 'Completed']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(subjectsProvider.notifier).updateTopicStatus(subject.id, topic.id, val);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Topic status updated to $val.')));
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
