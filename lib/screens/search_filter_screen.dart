import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import '../models/models.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  String _searchQuery = '';
  String? _selectedSubjectId;
  String? _selectedStatus;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final sessions = ref.watch(sessionsProvider);

    List<Map<String, dynamic>> allTopics = [];
    for (var subject in subjects) {
      for (var topic in subject.topics) {
        allTopics.add({
          'subjectId': subject.id,
          'subjectName': subject.name,
          'topic': topic,
        });
      }
    }

    var filteredTopics = allTopics.where((item) {
      final topic = item['topic'] as Topic;
      final matchesQuery = topic.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSubject = _selectedSubjectId == null || item['subjectId'] == _selectedSubjectId;
      final matchesStatus = _selectedStatus == null || topic.status == _selectedStatus;
      final matchesDate = _selectedDate == null || sessions.any((s) => 
        s.topicId == topic.id && 
        s.dateTime.year == _selectedDate!.year && 
        s.dateTime.month == _selectedDate!.month && 
        s.dateTime.day == _selectedDate!.day
      );
      
      return matchesQuery && matchesSubject && matchesStatus && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Topic by Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedSubjectId,
                    decoration: const InputDecoration(labelText: 'Filter by Subject', border: OutlineInputBorder()),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Subjects')),
                      ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedSubjectId = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Filter by Status', border: OutlineInputBorder()),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Status')),
                      const DropdownMenuItem(value: 'Not Started', child: Text('Not Started')),
                      const DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                      const DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatus = val),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null 
                        ? 'Filter by Session Date' 
                        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => setState(() => _selectedDate = null),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTopics.length,
              itemBuilder: (ctx, i) {
                final item = filteredTopics[i];
                final topic = item['topic'] as Topic;
                return ListTile(
                  title: Text(topic.name),
                  subtitle: Text('${item['subjectName']} • ${topic.status}'),
                  trailing: Text('${topic.estimatedMinutes} mins'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
