import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/data_provider.dart';

class SubjectManagementScreen extends ConsumerStatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  ConsumerState<SubjectManagementScreen> createState() => _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends ConsumerState<SubjectManagementScreen> {
  final _uuid = const Uuid();

  void _showAddSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subject Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(subjectsProvider.notifier).addSubject(
                  Subject(id: _uuid.v4(), name: controller.text, topics: []),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog(Subject subject) {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Topic to ${subject.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Topic Name'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Estimated Time (mins)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && timeController.text.isNotEmpty) {
                final time = int.tryParse(timeController.text) ?? 60;
                ref.read(subjectsProvider.notifier).addTopic(
                  subject.id,
                  Topic(id: _uuid.v4(), name: nameController.text, estimatedMinutes: time),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSubjectDialog,
          ),
        ],
      ),
      body: subjects.isEmpty
          ? const Center(child: Text('No subjects added. Tap + to add.'))
          : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (ctx, i) {
                final subject = subjects[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(subject.name),
                    subtitle: Text('${subject.topics.length} topics'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _showAddTopicDialog(subject),
                    ),
                    children: subject.topics.map((topic) {
                      return ListTile(
                        title: Text(topic.name),
                        subtitle: Text('${topic.estimatedMinutes} mins • ${topic.status}'),
                        leading: const Icon(Icons.article_outlined),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
