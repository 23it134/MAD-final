import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class Topic extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int estimatedMinutes;

  @HiveField(3)
  String status; // 'Not Started', 'In Progress', 'Completed'

  Topic({
    required this.id,
    required this.name,
    required this.estimatedMinutes,
    this.status = 'Not Started',
  });
}

@HiveType(typeId: 1)
class Subject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Topic> topics;

  Subject({
    required this.id,
    required this.name,
    required this.topics,
  });

  double get completionPercentage {
    if (topics.isEmpty) return 0.0;
    int completed = topics.where((t) => t.status == 'Completed').length;
    return completed / topics.length;
  }
}

@HiveType(typeId: 2)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String topicId;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  int durationMinutes;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.dateTime,
    required this.durationMinutes,
  });
}
