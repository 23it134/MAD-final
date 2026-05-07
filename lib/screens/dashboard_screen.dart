import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSyncing = false;

  void _syncData() async {
    setState(() => _isSyncing = true);
    
    try {
      final subjects = ref.read(subjectsProvider);
      final sessions = ref.read(sessionsProvider);

      final payload = {
        'subjects': subjects.map((s) => {
          'id': s.id,
          'name': s.name,
          'topics': s.topics.map((t) => {
            'id': t.id,
            'name': t.name,
            'estimatedMinutes': t.estimatedMinutes,
            'status': t.status,
          }).toList(),
        }).toList(),
        'sessions': sessions.map((s) => {
          'id': s.id,
          'subjectId': s.subjectId,
          'topicId': s.topicId,
          'dateTime': s.dateTime.toIso8601String(),
          'durationMinutes': s.durationMinutes,
        }).toList(),
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/sync'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data successfully synchronized with MongoDB Atlas!')),
          );
        } else {
          throw Exception('Failed to sync: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e. Is the Node server running?')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final sessions = ref.watch(sessionsProvider);

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

    // Daily Study Progress Logic
    final today = DateTime.now();
    int todayPlannedMinutes = 0;
    int todaySessionsCount = 0;
    
    for (var session in sessions) {
      if (session.dateTime.year == today.year && 
          session.dateTime.month == today.month && 
          session.dateTime.day == today.day) {
        todayPlannedMinutes += session.durationMinutes;
        todaySessionsCount++;
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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          _isSyncing
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_sync),
                  tooltip: 'Sync Data',
                  onPressed: _syncData,
                ),
        ],
      ),
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
            Text('Daily Study Progress', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              color: Colors.indigo.withValues(alpha: 0.1),
              child: ListTile(
                leading: const Icon(Icons.today, color: Colors.indigo, size: 32),
                title: Text('Today\'s Plan: $todaySessionsCount session(s)'),
                subtitle: Text('Total Time: ${todayPlannedMinutes ~/ 60}h ${todayPlannedMinutes % 60}m'),
                trailing: CircularProgressIndicator(
                  value: todayPlannedMinutes > 0 ? 1.0 : 0.0, // Mock progress based on planning
                  color: Colors.indigo,
                  backgroundColor: Colors.indigo.withValues(alpha: 0.2),
                ),
              ),
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
