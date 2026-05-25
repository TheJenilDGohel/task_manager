import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class AddTask extends TaskEvent {
  final String title;
  final String description;

  const AddTask({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class ToggleTaskCompletion extends TaskEvent {
  final Task task;

  const ToggleTaskCompletion(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String id;

  const DeleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

class UndoDelete extends TaskEvent {
  final Task task;

  const UndoDelete(this.task);

  @override
  List<Object?> get props => [task];
}
