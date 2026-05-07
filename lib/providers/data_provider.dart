import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class SubjectsNotifier extends Notifier<List<Subject>> {
  @override
  List<Subject> build() {
    return ref.read(storageServiceProvider).getSubjects();
  }

  Future<void> addSubject(Subject subject) async {
    await ref.read(storageServiceProvider).addSubject(subject);
    state = ref.read(storageServiceProvider).getSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    await ref.read(storageServiceProvider).updateSubject(subject);
    state = ref.read(storageServiceProvider).getSubjects();
  }

  Future<void> deleteSubject(String id) async {
    await ref.read(storageServiceProvider).deleteSubject(id);
    state = ref.read(storageServiceProvider).getSubjects();
  }

  Future<void> addTopic(String subjectId, Topic topic) async {
    final subject = state.firstWhere((s) => s.id == subjectId);
    subject.topics.add(topic);
    subject.save(); // HiveObject save
    state = ref.read(storageServiceProvider).getSubjects();
  }

  Future<void> updateTopicStatus(String subjectId, String topicId, String newStatus) async {
    final subject = state.firstWhere((s) => s.id == subjectId);
    final topic = subject.topics.firstWhere((t) => t.id == topicId);
    topic.status = newStatus;
    subject.save();
    state = ref.read(storageServiceProvider).getSubjects();
  }
}

final subjectsProvider = NotifierProvider<SubjectsNotifier, List<Subject>>(() {
  return SubjectsNotifier();
});

class SessionsNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    return ref.read(storageServiceProvider).getSessions();
  }

  Future<void> addSession(StudySession session) async {
    await ref.read(storageServiceProvider).addSession(session);
    state = ref.read(storageServiceProvider).getSessions();
  }

  Future<void> deleteSession(String id) async {
    await ref.read(storageServiceProvider).deleteSession(id);
    state = ref.read(storageServiceProvider).getSessions();
  }
}

final sessionsProvider = NotifierProvider<SessionsNotifier, List<StudySession>>(() {
  return SessionsNotifier();
});
