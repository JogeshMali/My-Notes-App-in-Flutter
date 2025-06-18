import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';

class MySqlDbHelper {
  static final String host = '127.0.0.1',
      //user = 'root',
      db = 'MyNotes',
      password = '';
  static final int port = 3306;
  static final String TABLE_NAME = 'notes';
  static final String COLUMN_SR_NO = 'S_No';
  static final String COLUMN_TITLE = 'Title';
  static final String COLUMN_DESCRIPTION = 'Description';

  MySqlDbHelper._();
  static final MySqlDbHelper instance = MySqlDbHelper._();

  MySqlConnection? conn;
  Future<MySqlConnection> getConnection() async {
    var setting = new ConnectionSettings(
        host: host,
        //user: user,
        db: db,
        password: password,
        port: port);
    return await MySqlConnection.connect(setting);
  }

  Future<void> openDatabase() async {
    conn ??= await getConnection();
    await conn!.query(
        'CREATE TABLE IF NOT EXISTS $TABLE_NAME($COLUMN_SR_NO INT PRIMARY KEY AUTO_INCREMENT , $COLUMN_TITLE TEXT,$COLUMN_DESCRIPTION TEXT )');
  }

  Future<bool> addNotes(
      {required String title, required String description}) async {
    conn ??= await getConnection();
    var result = await conn!.query(
        'INSERT INTO $TABLE_NAME($COLUMN_TITLE, $COLUMN_DESCRIPTION) VALUES(?,?)',
        [title, description]);
    return result.affectedRows! > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    conn ??= await getConnection();
    var results = await conn!.query('SELECT * FROM $TABLE_NAME');

    return results.map((row) {
      return {
        COLUMN_SR_NO: row[COLUMN_SR_NO],
        COLUMN_TITLE: row[COLUMN_TITLE] is Uint8List
            ? String.fromCharCodes(row[COLUMN_TITLE])
            : row[COLUMN_TITLE],
        COLUMN_DESCRIPTION: row[COLUMN_DESCRIPTION] is Uint8List
            ? String.fromCharCodes(row[COLUMN_DESCRIPTION])
            : row[COLUMN_DESCRIPTION],
      };
    }).toList();
  }

  Future<bool> updateNotes(
      {required String title,
      required String description,
      required int S_No}) async {
    conn ??= await getConnection();
    var result = await conn!.query(
        'UPDATE  $TABLE_NAME SET $COLUMN_TITLE = ? , $COLUMN_DESCRIPTION = ? WHERE $COLUMN_SR_NO = ?',
        [title, description, S_No]);
    return result.affectedRows! > 0;
  }

  Future<bool> deleteNotes({required int S_No}) async {
    conn ??= await getConnection();
    var result = await conn!
        .query('DELETE FROM $TABLE_NAME WHERE $COLUMN_SR_NO = ?', [S_No]);
    return result.affectedRows! > 0;
  }
}
