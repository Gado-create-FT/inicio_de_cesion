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
    // Solución para SQLite en Windows, Mac y Linux
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = await getDatabasesPath();
    final databasePath = join(path, 'users.db');

    return await openDatabase(
      databasePath,
      version: 2, // Asegura que la base de datos esté actualizada
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT DEFAULT 'user'  -- Los usuarios normales tienen el rol 'user'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'user'");
        }
      },
    );
  }

  // ✅ REGISTRAR USUARIO CON ASIGNACIÓN AUTOMÁTICA DE ADMINISTRADOR
  Future<int> registerUser(String firstName, String lastName, String email, String password) async {
    final db = await database;

    // Lista de correos predefinidos que serán administradores
    List<String> adminEmails = ["admin@gmail.com", "gado@gmail.com"];

    // Si el correo está en la lista, será admin; si no, será usuario normal
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
    );
  }

  // ✅ INICIAR SESIÓN Y OBTENER DATOS DEL USUARIO
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return users.isNotEmpty ? users.first : null;
  }

  // ✅ OBTENER TODOS LOS USUARIOS (Para que un admin pueda verlos)
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // ✅ ELIMINAR UN USUARIO POR ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ CERRAR SESIÓN (Opcional, limpia la instancia de la base de datos)
  Future<void> logout() async {
    _database = null;
  }
}
