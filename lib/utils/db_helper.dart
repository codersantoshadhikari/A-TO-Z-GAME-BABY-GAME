import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'deckwithcard4.db';
  static const int _databaseVersion = 1;
  bool exists = false;

  DBHelper._();
  static final DBHelper _singleton = DBHelper._();
  factory DBHelper() => _singleton;

  Database? _database;

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);
    var db = await openDatabase(dbPath, version: _databaseVersion,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE decks(
            id INTEGER PRIMARY KEY,
            title TEXT
          )
        ''');

      await db.execute('''
          CREATE TABLE flashcards(
            id INTEGER PRIMARY KEY,
            question TEXT,
            answer TEXT,
            deck_id  INTEGER,
            FOREIGN KEY (deck_id) REFERENCES decks(id)
          )
        ''');
    });
    return db;
  }

  Future<bool> checkIfDBExists() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);
    return await databaseExists(dbPath);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table) : db.query(table, where: where);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> update(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<void> deleteFlashCardByDeckId(String table, int deckId) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
  }

  Future<void> delete(String table, int id) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Future<Map<int, int>> getCountOfCards() async {
  //   final db = await this.db;
  //   var result = await db.rawQuery(
  //       "SELECT deckId, COUNT(id) as cardCount FROM flashcards GROUP BY deckId");
  //   Map<int, int> countsMap = {
  //     for (var e in result) e['deckId']: e['cardCount']
  //   };
  //   return countsMap;
  // }
}
