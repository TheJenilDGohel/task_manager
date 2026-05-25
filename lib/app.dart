import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/pages/task_list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const TaskListPage(),
    );
  }
}
