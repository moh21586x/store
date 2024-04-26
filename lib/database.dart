

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database db;

class ModelDB {
  //todo check is id can be null
  int? id;
  String name = "";
  String place = "";
  String description = "";
  String? img1;
  String? img2;
  String? img3;
  String? img4;
  String? img5;
  String? img6;
  String? img7;
  String? img8;
  String? img9;
  String? img10;

  ModelDB(
      {this.id,
      required this.name,
      required this.place,
      required this.description,
      this.img1,
      this.img2,
      this.img3,
      this.img4,
      this.img5,
      this.img6,
      this.img7,
      this.img8,
      this.img9,
      this.img10});

  @override
  String toString() {
    return '''ModelClass{id:$id, name: $name, place: $place, description: $description,
     images(1-10): $img1/$img2/$img3/$img4/$img5/$img6/$img7/$img8/$img9/$img10}''';
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'place': place, 'description':description,
    'img1':img1,'img2':img2,'img3':img3,'img4':img4,'img5':img5,'img6':img6,
      'img7':img7,'img8':img8,'img9':img9,'img10':img10,};
  }
}

class DBHelper {
  static const databaseName = "storeDB.db";
  static const databaseVersion = 1;
  static const table = "tbl_store";

  static const col1 = "id";
  static const col2 = "name";
  static const col3 = "place";
  static const col4 = "description";
  static const col5 = "img1";
  static const col6 = "img2";
  static const col7 = "img3";
  static const col8 = "img4";
  static const col9 = "img5";
  static const col10 = "img6";
  static const col11 = "img7";
  static const col12 = "img8";
  static const col13 = "img9";
  static const col14 = "img10";

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> get database async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(path, version: databaseVersion,
        onCreate: (db, version) {
      //todo implement auto increment maybe
      return db.execute('''CREATE TABLE $table(
    $col1 INTEGER PRIMARY KEY,$col2 TEXT,$col3 TEXT,$col4 TEXT,
    $col5 TEXT,$col6 TEXT,$col7 TEXT,$col8 TEXT,$col9 TEXT,
    $col10 TEXT,$col11 TEXT,$col12 TEXT,$col13 TEXT,$col14 TEXT
    )''');
    });
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.

  Future insert(ModelDB row, ) async {
    try {
      await db.insert(
        table,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      //todo return operation result
      print('Db Inserted');
    } catch (e) {
      print('DbException $e');
    }
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryFilterRows() async {
    return await db.rawQuery("select * from $table where stCol2='111'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  // Future<int> update(Map<String, dynamic> row) async {
  // Database db = await instance.database;
  //   int id = row[columnId];
  //   return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  // }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id, ) async {
    return await db.delete(DBHelper.table, where: "id =?", whereArgs: [id]);
  }
}
