import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zendo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType UNIQUE,
        password $textType,
        profileImage TEXT,
        createdAt $textType
      )
    ''');

    // Tasks table with userId foreign key
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        userId $integerType,
        title $textType,
        category $textType,
        priority $textType,
        isCompleted $integerType,
        createdAt $textType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from old structure to new
      await db.execute('DROP TABLE IF EXISTS user_profile');
    }
  }

  // User Operations
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> createUser(String name, String email, String password) async {
    final db = await instance.database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'profileImage': null,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(int userId, Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Task Operations (USER-SPECIFIC)
  Future<int> createTask(int userId, Map<String, dynamic> task) async {
    final db = await instance.database;
    task['userId'] = userId;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> readAllTasks(int userId) async {
    final db = await instance.database;
    return await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'isCompleted ASC, createdAt DESC',
    );
  }

  Future<int> updateTask(int taskId, Map<String, dynamic> task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Task Statistics (USER-SPECIFIC)
  Future<Map<String, int>> getTaskStatistics(int userId) async {
    final db = await instance.database;
    final tasks = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    int total = tasks.length;
    int completed = tasks.where((t) => t['isCompleted'] == 1).length;
    int pending = total - completed;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }

  // Weekly Productivity (USER-SPECIFIC)
  Future<List<int>> getWeeklyProductivity(int userId) async {
    final db = await instance.database;
    List<int> weeklyData = [0, 0, 0, 0, 0, 0, 0];

    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final tasks = await db.query(
        'tasks',
        where: 'userId = ? AND createdAt >= ? AND createdAt < ?',
        whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      weeklyData[i] = tasks.length;
    }

    return weeklyData;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}