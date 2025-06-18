import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final String TABLE_NAME = 'notes';
  static final String COLUMN_SR_NO = 'S_No';
  static final String COLUMN_TITLE = 'Title';
  static final String COLUMN_DESCRIPTION = 'Description';

  DBHelper._();
  static final DBHelper getInstance = DBHelper._();
  Database? myDb;
  Future<Database> getDB() async {
    myDb ??= await openDB();
    return myDb!;
  }

  Future<Database> openDB() async {
    Directory dirPath = await getApplicationDocumentsDirectory();
    String dbPath = join(dirPath.path, 'notes.db');
    return await openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          'CREATE TABLE $TABLE_NAME ($COLUMN_SR_NO INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_TITLE TEXT, $COLUMN_DESCRIPTION TEXT)');
    }, version: 1);
  }

  Future<bool> addNotes(
      {required String title, required String description}) async {
    var db = await getDB();
    int rowsAffected = await db.insert(
        TABLE_NAME, {COLUMN_TITLE: title, COLUMN_DESCRIPTION: description});
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NAME);
    return mData;
  }

  Future<bool> updateNotes(
      {required String title,
      required String description,
      required int S_No}) async {
    var db = await getDB();
    int rowsAffected = await db.update(
        TABLE_NAME, {COLUMN_TITLE: title, COLUMN_DESCRIPTION: description},
        where: '$COLUMN_SR_NO == $S_No');
    return rowsAffected > 0;
  }

  Future<bool> deleteNotes({required int S_No}) async {
    var db = await getDB();
    int rowsAffected =
        await db.delete(TABLE_NAME, where: '$COLUMN_SR_NO == $S_No');
    return rowsAffected > 0;
  }
}
