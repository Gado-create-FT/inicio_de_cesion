import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static DatabaseHelper get instance => _instance;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Inicializa la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Configura y crea la base de datos
  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = await getDatabasesPath();
    final databasePath = join(path, 'users.db');

    return await openDatabase(
      databasePath,
      version: 6, // Aumenta si haces cambios en la estructura
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT DEFAULT 'user'
          )
        ''');

        await db.execute('''
          CREATE TABLE markers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            latitude REAL,
            longitude REAL,
            user_email TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 6) {
          await db.execute("ALTER TABLE markers ADD COLUMN user_email TEXT");
        }
      },
    );
  }

  // --------------------------
  // 🧑‍💻 Funciones de Usuarios
  // --------------------------

  Future<int> registerUser(String firstName, String lastName, String email, String password) async {
    final db = await database;
    List<String> adminEmails = ["admin@gmail.com", "gado@gmail.com"];
    String role = adminEmails.contains(email) ? 'admin' : 'user';

    return await db.insert(
      'users',
      {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'role': role,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty ? users.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(String email, String firstName, String lastName, String password) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'first_name': firstName,
        'last_name': lastName,
        'password': password.isNotEmpty ? password : null,
      },
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // --------------------------
  // 📍 Funciones de Marcadores
  // --------------------------

  Future<int> insertMarker(String title, String description, double latitude, double longitude, String email) async {
    final db = await database;

    return await db.insert(
      'markers',
      {
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'user_email': email,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMarkers() async {
    final db = await database;
    return await db.query('markers');
  }

  Future<List<Map<String, dynamic>>> getMarkersByEmail(String email) async {
    final db = await database;
    return await db.query('markers', where: 'user_email = ?', whereArgs: [email]);
  }

  Future<int> updateMarker(int id, String title, String description) async {
    final db = await database;
    return await db.update(
      'markers',
      {
        'title': title,
        'description': description,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMarker(int id) async {
    final db = await database;
    await db.delete('markers', where: 'id = ?', whereArgs: [id]);
  }

  // --------------------------
  // 🔒 Logout
  // --------------------------
  Future<void> logout() async {
    _database = null;
  }
}
