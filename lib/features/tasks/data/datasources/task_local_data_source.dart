import 'package:path/path.dart';
import 'package:snug_logger/snug_logger.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';

class TaskLocalDataSource {
  // Singleton — one DB connection for the whole app lifetime.
  static final TaskLocalDataSource _instance = TaskLocalDataSource._internal();

  factory TaskLocalDataSource() => _instance;

  TaskLocalDataSource._internal();

  Database? _db;

  // Lazy-init so the DB opens on first actual use, not at app start.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${TaskModel.tableName} (
            ${TaskModel.colId} TEXT PRIMARY KEY,
            ${TaskModel.colTitle} TEXT NOT NULL,
            ${TaskModel.colDescription} TEXT,
            ${TaskModel.colIsCompleted} INTEGER NOT NULL DEFAULT 0,
            ${TaskModel.colCreatedAt} TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add ALTER TABLE statements here when bumping the version number.
      },
    );

    snugLog('Database opened at tasks.db v1', logType: LogType.info);
    return db;
  }

  Future<void> insertTask(TaskModel task) async {
    try {
      final db = await database;
      await db.insert(
        TaskModel.tableName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      snugLog('Inserted task id: ${task.id}', logType: LogType.debug);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<TaskModel>> getAllTasks() async {
    try {
      final db = await database;
      final maps = await db.query(TaskModel.tableName, orderBy: '${TaskModel.colCreatedAt} DESC');
      final result = maps.map((map) => TaskModel.fromMap(map)).toList();
      snugLog('Fetched ${result.length} tasks from DB', logType: LogType.debug);
      return result;
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await database;
      await db.update(
        TaskModel.tableName,
        task.toMap(),
        where: '${TaskModel.colId} = ?',
        whereArgs: [task.id],
      );
      snugLog('Updated task id: ${task.id}', logType: LogType.debug);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final db = await database;
      await db.delete(
        TaskModel.tableName,
        where: '${TaskModel.colId} = ?',
        whereArgs: [id],
      );
      snugLog('Deleted task id: $id', logType: LogType.debug);
    } catch (e, stackTrace) {
      snugLog(e.toString(), logType: LogType.error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
      snugLog('Database closed', logType: LogType.info);
    }
  }
}
