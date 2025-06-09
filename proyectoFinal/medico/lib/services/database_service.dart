// services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            imagePath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE appointments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            date TEXT,
            reason TEXT,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<int> createUser(User user) async {
  final db = _db!;
  return await db.insert('users', user.toMap());
}

  Future<User?> getUser(String username, String password) async {
    final List<Map<String, dynamic>> maps = await _db!.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> userExists(String username) async {
    final result = await _db!.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<int> createAppointment(Appointment appt) async {
    return await _db!.insert('appointments', appt.toMap());
  }

  Future<List<Appointment>> getAppointmentsForUser(int userId) async {
    final List<Map<String, dynamic>> maps = await _db!.query(
      'appointments',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((e) => Appointment.fromMap(e)).toList();
  }
}
