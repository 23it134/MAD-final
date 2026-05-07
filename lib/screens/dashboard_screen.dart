import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    int totalSubjects = subjects.length;
    int completedTopics = 0;
    int pendingTopics = 0;
    
    for (var subject in subjects) {
      for (var topic in subject.topics) {
        if (topic.status == 'Completed') {
          completedTopics++;
        } else {
          pendingTopics++;
        }
      }
    }

    // Logic to suggest next topics (basic: first pending topic from subject with lowest completion)
    var sortedSubjects = List.from(subjects)..sort((a, b) => a.completionPercentage.compareTo(b.completionPercentage));
    var nextTopics = <String>[];
    if (sortedSubjects.isNotEmpty) {
      for (var s in sortedSubjects) {
        var pending = s.topics.where((t) => t.status != 'Completed');
        if (pending.isNotEmpty) {
          nextTopics.add('${s.name}: ${pending.first.name}');
        }
        if (nextTopics.length >= 2) break; // Suggest max 2
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Subjects', totalSubjects.toString(), Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Completed', completedTopics.toString(), Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Pending', pendingTopics.toString(), Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Needs Attention', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (sortedSubjects.isNotEmpty)
              Card(
                child: ListTile(
                  title: Text(sortedSubjects.first.name),
                  subtitle: Text('Completion: ${(sortedSubjects.first.completionPercentage * 100).toStringAsFixed(1)}%'),
                  trailing: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                ),
              )
            else
              const Text('No subjects added yet.'),
            const SizedBox(height: 24),
            Text('Suggested Next Topics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (nextTopics.isNotEmpty)
              ...nextTopics.map((t) => Card(child: ListTile(title: Text(t), leading: const Icon(Icons.lightbulb_outline))))
            else
              const Text('No pending topics found.'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
