// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database db;

class ModelDB {
  //todo check is id can be null
  int? id;
  String item = "";
  String location = "";
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
      required this.item,
      required this.location,
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
    return '''ModelClass{id:$id, name/item: $item, place/location: $location, description: $description,
     images(1-10): $img1/$img2/$img3/$img4/$img5/$img6/$img7/$img8/$img9/$img10}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': item,
      'place': location,
      'description': description,
      'img1': img1,
      'img2': img2,
      'img3': img3,
      'img4': img4,
      'img5': img5,
      'img6': img6,
      'img7': img7,
      'img8': img8,
      'img9': img9,
      'img10': img10,
    };
  }

  factory ModelDB.fromQuery(Map<String, dynamic> row) => ModelDB(
        id: row[DBHelper.col1],
        item: row[DBHelper.col2],
        location: row[DBHelper.col3],
        description: row[DBHelper.col4],
        img1: row[DBHelper.col5],
        img2: row[DBHelper.col6],
        img3: row[DBHelper.col7],
        img4: row[DBHelper.col8],
        img5: row[DBHelper.col9],
        img6: row[DBHelper.col10],
        img7: row[DBHelper.col11],
        img8: row[DBHelper.col12],
        img9: row[DBHelper.col13],
        img10: row[DBHelper.col14],
      );

  Future<List<ModelDB>> toModel(List rows) async {
    return List.generate(10, (index) {
      return ModelDB(
        id: rows[index][DBHelper.col1],
        item: rows[index][DBHelper.col2],
        location: rows[index][DBHelper.col3],
        description: rows[index][DBHelper.col4],
        img1: rows[index][DBHelper.col5],
        img2: rows[index][DBHelper.col6],
        img3: rows[index][DBHelper.col7],
        img4: rows[index][DBHelper.col8],
        img5: rows[index][DBHelper.col9],
        img6: rows[index][DBHelper.col10],
        img7: rows[index][DBHelper.col11],
        img8: rows[index][DBHelper.col12],
        img9: rows[index][DBHelper.col13],
        img10: rows[index][DBHelper.col14],
      );
    });
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

  Future insert(
    ModelDB row,
  ) async {
    try {
      await db.insert(
        table,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      //todo return operation result
      return db.rawQuery('SELECT last_insert_rowid()');
    } catch (e) {
      return 'DbException $e';
    }
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllImages() async {
    return await db.rawQuery("SELECT $col5,$col6,$col7,$col8,$col9,$col10,$col11,$col12,$col13,$col14 FROM $table");
  }


  Future<List<Map<String, dynamic>>> queryAllRowsDisplay() async {
    return await db.rawQuery("SELECT $col1,$col2,$col3,$col4,$col5 FROM $table");
  }

  Future<List<Map<String, dynamic>>> queryFilteredRows(String search) async {
    return await db.rawQuery(
        "SELECT $col1, $col2,$col3,$col4,$col5 FROM $table WHERE $col2 like '%$search%' or $col3 like '%$search%' or $col4 like '%$search%' ");

  }

  Future<List<Map<String, dynamic>>> queryFilterRow(int id) async {
    return await db.query(table, where: 'id =?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await db.delete(table, where: "id =?", whereArgs: [id]);
  }
}
