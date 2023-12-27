import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      email TEXT,
      address TEXT,
      phone INTEGER,
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  static Future<int> createData(
      String name, String email, String? address, int? phone) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'email': email,
      'address': address,
      'phone': phone
    };
    final id = await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData(String? orderby) async {
    final db = await SQLHelper.db();
    return db.query("data", orderBy: orderby);
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query("data", where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(
      int id, String name, String email, String address, int? phone) async {
    final db = await SQLHelper.db();
    final data = {
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'createAt': DateTime.now().toString()
    };
    final result =
        await db.update('data', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }
}
