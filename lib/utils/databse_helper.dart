import 'dart:io';

import 'package:faceattendance/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'users';
  static const columnId = 'id';
  static const columnUser = 'user';
  static const columnarrayKey= 'arrayKey';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnUser TEXT NOT NULL,
            $columnarrayKey TEXT NOT NULL )
          ''');
  }


  // Future<int> insert(Map<String, dynamic> row) async {
  //   Database db = await database;
  //   return await db.insert(table, row);
  // }
  Future<int> insert(User user) async {
    Database db = await instance.database;
    print("user json ");
    print(user.toJson());
    return await db.insert(table, user.toJson());
  }


  // Future<List<Map<String, dynamic>>> queryAllUsers() async {
  //   Database db = await database;
  //   var result = await db.query(table);
  //
  //   return result.toList();
  //   // await db.rawQuery(TABLE_STUDENT);
  // }
  Future<List<User>> queryAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(table);
    print(users.length);
    if(users.isNotEmpty){
      return users.map((u) => User.fromJson(u)).toList();
    }else{
      return [];
    }

  }

  // Future<List<User>> queryAllUsers() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> users = await db.query(table);
  //   return users.map((u) => User.fromJson(u)).toList();
  // }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
