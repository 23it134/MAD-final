import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static const String subjectsBoxName = 'subjectsBox';
  static const String sessionsBoxName = 'sessionsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TopicAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(StudySessionAdapter());

    await Hive.openBox<Subject>(subjectsBoxName);
    await Hive.openBox<StudySession>(sessionsBoxName);
  }

  Box<Subject> get subjectsBox => Hive.box<Subject>(subjectsBoxName);
  Box<StudySession> get sessionsBox => Hive.box<StudySession>(sessionsBoxName);

  List<Subject> getSubjects() => subjectsBox.values.toList();
  
  Future<void> addSubject(Subject subject) async {
    await subjectsBox.put(subject.id, subject);
  }

  Future<void> updateSubject(Subject subject) async {
    await subjectsBox.put(subject.id, subject);
  }

  Future<void> deleteSubject(String id) async {
    await subjectsBox.delete(id);
  }

  List<StudySession> getSessions() => sessionsBox.values.toList();

  Future<void> addSession(StudySession session) async {
    await sessionsBox.put(session.id, session);
  }
  
  Future<void> deleteSession(String id) async {
    await sessionsBox.delete(id);
  }
}
