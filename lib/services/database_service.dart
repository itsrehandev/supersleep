import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/alarm_model.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'supersleep_alarms.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id TEXT PRIMARY KEY,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL,
            label TEXT NOT NULL,
            repeat_days TEXT NOT NULL,
            is_enabled INTEGER NOT NULL,
            ringtone_name TEXT NOT NULL,
            ringtone_path TEXT,
            math_mission_enabled INTEGER NOT NULL,
            math_difficulty TEXT NOT NULL,
            typing_mission_enabled INTEGER NOT NULL,
            typing_difficulty TEXT NOT NULL,
            qr_mission_enabled INTEGER NOT NULL,
            vibration_enabled INTEGER NOT NULL,
            volume_percentage REAL NOT NULL,
            gradual_volume_enabled INTEGER NOT NULL,
            gradual_duration_seconds INTEGER NOT NULL,
            snooze_enabled INTEGER NOT NULL,
            snooze_interval_minutes INTEGER NOT NULL,
            next_fire_epoch INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertAlarm(Alarm alarm) async {
    final db = await database;
    await db.insert(
      'alarms',
      alarm.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final db = await database;
    await db.update(
      'alarms',
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  Future<void> deleteAlarm(String id) async {
    final db = await database;
    await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('alarms');
    return List.generate(maps.length, (i) => Alarm.fromMap(maps[i]));
  }
}
