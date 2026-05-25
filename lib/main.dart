import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snug_logger/snug_logger.dart';

import 'app.dart';
import 'core/security/blocked_screen.dart';
import 'core/security/security_service.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/add_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/get_all_tasks.dart';
import 'features/tasks/domain/usecases/update_task.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final securityResult = await SecurityService().check();

  snugLog(
    'Security check → compromised: ${securityResult.isCompromised}, '
    'emulator: ${securityResult.isEmulator}',
    logType: LogType.info,
  );

  if (securityResult.detectedIssues.isNotEmpty) {
    snugLog(
      'Issues: ${securityResult.detectedIssues}',
      logType: LogType.production,
    );
  }

  // reverse the condition if running on emulator
  if (securityResult.isCompromised) {
    runApp(BlockedScreen(issues: securityResult.detectedIssues));
    return;
  }

  final taskLocalDataSource = TaskLocalDataSource();
  final taskRepository = TaskRepositoryImpl(taskLocalDataSource);


  final getAllTasks = GetAllTasks(taskRepository);
  final addTask = AddTask(taskRepository);
  final updateTask = UpdateTask(taskRepository);
  final deleteTask = DeleteTask(taskRepository);


  final taskBloc = TaskBloc(
    getAllTasksUseCase: getAllTasks,
    addTaskUseCase: addTask,
    updateTaskUseCase: updateTask,
    deleteTaskUseCase: deleteTask,
  );

  runApp(
    BlocProvider<TaskBloc>(
      create: (_) => taskBloc,
      child: const App(),
    ),
  );
}
