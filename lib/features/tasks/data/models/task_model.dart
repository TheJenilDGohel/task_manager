import '../../domain/entities/task.dart';

class TaskModel extends Task {
  static const String tableName = 'tasks';
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colIsCompleted = 'is_completed';
  static const String colCreatedAt = 'created_at';

  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map[colId] as String,
      title: map[colTitle] as String,
      description: map[colDescription] as String? ?? '',
      isCompleted: (map[colIsCompleted] as int) == 1,
      createdAt: DateTime.parse(map[colCreatedAt] as String),
    );
  }

  // SQLite has no bool or DateTime — we store them as int (0/1) and ISO8601 text.
  Map<String, dynamic> toMap() {
    return {
      colId: id,
      colTitle: title,
      colDescription: description,
      colIsCompleted: isCompleted ? 1 : 0,
      colCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
  }
}
