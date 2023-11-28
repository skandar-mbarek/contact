import 'package:path/path.dart' ;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute(""" CREATE TABLE contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    nom TEXT,
    tel TEXT,
    image TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  static Future<Database> db() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    return openDatabase('first.db', version: 1,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createContact(String nom, String tel,
      String? image) async {
    final db = await SQLHelper.db();
    final data = {'nom': nom, 'tel': tel, 'image': image};
    final id = await db.insert(
        'contacts', data, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await SQLHelper.db();
    return db.query('contacts', orderBy: "id");
  }


  static Future<List<Map<String, dynamic>>> getContact(int id) async {
    final db = await SQLHelper.db();
    return db.query('Contacts', where: "id = ?", whereArgs: [id], limit: 1);
  }


  static Future<int> updateContacts(int id, String nom, String tel,
      String ? image) async {
    final db = await SQLHelper.db();
    final data = {
      'nom': nom,
      'tel': tel,
      'image': image,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update(
        'contacts', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteContact(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("contacts", where: "id=?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Somthing went wrong whene deleting: $err");
    }
  }
}
