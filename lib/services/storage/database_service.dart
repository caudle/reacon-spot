import 'package:dirm/modal/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

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
    // When creating the db, create the table

    await db.execute("CREATE TABLE User("
        "uid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "phone TEXT,"
        "email TEXT, "
        "name TEXT, "
        "dp TEXT, "
        "userType TEXT,"
        "isEmailVerified INTEGER,"
        "isPhoneVerified INTEGER,"
        "createdAt TEXT)");

    print("Created tables");
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int? res;

    try {
      res = await dbClient!.insert("User", user.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } on Exception catch (_) {
      print("error caught");
    }

    return res!;
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient!.query("User");
    return res.isNotEmpty ? true : false;
  }

  Future<User?> getUser() async {
    var dbClient = await db;
    List<Map<String, Object?>> maps = await dbClient!.query("User");
    return maps.isNotEmpty ? User.fromDbMap(maps[0]) : null;
  }
}
