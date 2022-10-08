import 'package:dirm/modal/listing.dart';
import 'package:dirm/modal/user.dart';
import 'package:dirm/modal/venue.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

import '../../modal/subcategory.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService.internal();
  factory DatabaseService() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseService.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables

    // users table
    await db.execute("CREATE TABLE User("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "userId TEXT,"
        "phone TEXT,"
        "email TEXT, "
        "name TEXT, "
        "dp TEXT, "
        "type TEXT,"
        "isemailVerified INTEGER,"
        "isphoneVerified INTEGER,"
        "createdAt TEXT)");
    // token
    await db.execute("CREATE TABLE Token("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "token TEXT"
        ")");

    /// home cats
    await db.execute("CREATE TABLE Subcategory("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "subId TEXT NOT NULL UNIQUE,"
        "category TEXT,"
        "name TEXT"
        ")");
  }

// user
  Future saveUser(User user) async {
    var dbClient = await db;
    try {
      await dbClient!.insert("User", user.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final dbClient = await db;
      final res = await dbClient!.query("User");
      return res.isNotEmpty ? true : false;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> getUser() async {
    try {
      var dbClient = await db;
      List<Map<String, Object?>> maps = await dbClient!.query("User");
      return maps.isNotEmpty ? User.fromDbMap(maps[0]) : null;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteUser() async {
    final dbClient = await db;
    try {
      await dbClient!.delete('User');
    } catch (e) {
      throw Exception(e);
    }
  }

// token
  Future saveToken(String token) async {
    var dbClient = await db;
    try {
      await dbClient!.insert("Token", {"token": token},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String?> getToken() async {
    try {
      var dbClient = await db;
      List<Map<String, Object?>> maps = await dbClient!.query("Token");
      return maps.isNotEmpty ? maps[0] as String : null;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteToken() async {
    final dbClient = await db;
    try {
      await dbClient!.delete('Token');
    } catch (e) {
      throw Exception(e);
    }
  }

  // cats
  Future saveSubcat(Subcategory subcat) async {
    var dbClient = await db;
    try {
      await dbClient!.insert("Subcategory", subcat.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Subcategory>> getSubcats() async {
    try {
      var dbClient = await db;
      List<Map<String, Object?>> maps = await dbClient!.query("Subcategory");
      return maps.isNotEmpty
          ? maps.map<Subcategory>((map) => Subcategory.fromDbMap(map)).toList()
          : [];
    } catch (e) {
      throw Exception(e);
    }
  }

  // get subcat by cat eg apartment from home or
  // commercial from land
  Future<List<Subcategory>> getSubcatsByCat(String cat) async {
    try {
      var dbClient = await db;
      List<Map<String, Object?>> maps = await dbClient!.query(
        "Subcategory",
        where: 'category = ?',
        whereArgs: [cat],
      );
      return maps.isNotEmpty
          ? maps.map<Subcategory>((map) => Subcategory.fromDbMap(map)).toList()
          : [];
    } catch (e) {
      throw Exception(e);
    }
  }
}
