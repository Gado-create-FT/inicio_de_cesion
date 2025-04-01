import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Este getter es lo que te falta
  static DatabaseHelper get instance => _instance;

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
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = await getDatabasesPath();
    final databasePath = join(path, 'users.db');

    return await openDatabase(
      databasePath,
      version: 5,  // Incrementar la versión al agregar nuevas tablas
      onCreate: (db, version) async {
        // Crear la tabla de usuarios (ya existente)
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

        // Crear la tabla de marcadores
        await db.execute('''
          CREATE TABLE markers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');

      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Crear la tabla de marcadores solo si es necesario
          await db.execute('''
            CREATE TABLE markers(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              latitude REAL,
              longitude REAL
            )
          ''');
        }
      },
    );
  }

  // Métodos para manejar los usuarios
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
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar si ya existe un usuario con el mismo email
    );
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    
    // Hacemos la consulta a la base de datos para obtener el usuario con el email y la contraseña
    List<Map<String, dynamic>> users = await db.query(
      'users',  // Nombre de la tabla
      where: 'email = ? AND password = ?',  // Condición de la búsqueda
      whereArgs: [email, password],  // Los parámetros para la búsqueda
    );

    // Si encontramos un usuario, lo devolvemos, si no, devolvemos null
    return users.isNotEmpty ? users.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Métodos para manejar los marcadores
  Future<int> insertMarker(String title, String description, double latitude, double longitude) async {
  final db = await database;

  return await db.insert(
    'markers',
    {
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar si ya existe
  );
}


  Future<List<Map<String, dynamic>>> getMarkers() async {
    final db = await database;
    return await db.query('markers');
  }

  Future<void> deleteMarker(int id) async {
    final db = await database;
    await db.delete('markers', where: 'id = ?', whereArgs: [id]);
  }

  // Actualizar usuario
  Future<int> updateUser(String email, String firstName, String lastName, String password) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'first_name': firstName,
        'last_name': lastName,
        'password': password.isNotEmpty ? password : null, // Solo actualizar si se proporciona una nueva contraseña
      },
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Eliminar usuario
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> logout() async {
    _database = null;
  }
}

