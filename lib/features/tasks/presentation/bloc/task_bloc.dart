import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snug_logger/snug_logger.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart' as use_cases;
import '../../domain/usecases/delete_task.dart' as use_cases;
import '../../domain/usecases/get_all_tasks.dart' as use_cases;
import '../../domain/usecases/update_task.dart' as use_cases;
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final use_cases.GetAllTasks getAllTasksUseCase;
  final use_cases.AddTask addTaskUseCase;
  final use_cases.UpdateTask updateTaskUseCase;
  final use_cases.DeleteTask deleteTaskUseCase;

  TaskBloc({
    required this.getAllTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTask>(_onDeleteTask);
    on<UndoDelete>(_onUndoDelete);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    snugLog('Loading tasks from database', logType: LogType.info);
    emit(const TaskLoading());
    try {
      final tasks = await getAllTasksUseCase();
      snugLog('Loaded ${tasks.length} task(s)', logType: LogType.info);
      emit(TaskLoaded(tasks));
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    snugLog('Adding task: "${event.title}"', logType: LogType.debug);
    try {
      // uuid here so IDs are stable across reinstalls and syncs.
      const uuid = Uuid();
      final task = Task(
        id: uuid.v4(),
        title: event.title,
        description: event.description,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await addTaskUseCase(task);
      await _reloadTasks(emit);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    snugLog('Updating task id: ${event.task.id}', logType: LogType.debug);
    try {
      await updateTaskUseCase(event.task);
      await _reloadTasks(emit);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    snugLog(
      'Toggling task "${event.task.title}" → ${!event.task.isCompleted}',
      logType: LogType.debug,
    );
    try {
      final updatedTask = event.task.copyWith(
        isCompleted: !event.task.isCompleted,
      );
      await updateTaskUseCase(updatedTask);
      await _reloadTasks(emit);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    snugLog('Deleting task id: ${event.id}', logType: LogType.debug);
    try {
      await deleteTaskUseCase(event.id);
      await _reloadTasks(emit);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUndoDelete(
    UndoDelete event,
    Emitter<TaskState> emit,
  ) async {
    snugLog(
      'Undoing delete for task: "${event.task.title}"',
      logType: LogType.info,
    );
    try {
      await addTaskUseCase(event.task);
      await _reloadTasks(emit);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      emit(TaskError(e.toString()));
    }
  }

  // Shared reload so every mutating handler doesn't duplicate the fetch.
  Future<void> _reloadTasks(Emitter<TaskState> emit) async {
    final tasks = await getAllTasksUseCase();
    emit(TaskLoaded(tasks));
  }
}
