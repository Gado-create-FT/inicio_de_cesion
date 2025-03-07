import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 👇 Solución para Windows, Mac y Linux
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = await getDatabasesPath();
    final databasePath = join(path, 'users.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  // ✅ REGISTRAR USUARIO
  Future<int> registerUser(String firstName, String lastName, String username, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'password': password,
      },
    );
  }

  // ✅ INICIAR SESIÓN (VALIDAR USUARIO)
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return users.isNotEmpty ? users.first : null;
  }

  // ✅ CERRAR SESIÓN (Opcional)
  Future<void> logout() async {
    _database = null;
  }

  // ✅ BORRAR TODOS LOS USUARIOS (Para pruebas)
  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('users');
  }
}
