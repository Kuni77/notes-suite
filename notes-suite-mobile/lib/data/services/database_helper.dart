import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';

    // Table notes
    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content_md $textType,
        tags $textType,
        visibility $textType,
        owner_email $textType,
        created_at $textType,
        updated_at $textType,
        is_synced $intType DEFAULT 1,
        local_id $textTypeNullable,
        pending_action $textTypeNullable
      )
    ''');

    // Table pending_operations (pour la file d'attente sync)
    await db.execute('''
      CREATE TABLE pending_operations (
        id $idType,
        operation_type $textType,
        note_id $intType,
        note_data $textType,
        created_at $textType,
        retries $intType DEFAULT 0
      )
    ''');
  }

  // CRUD Notes

  Future<Note> insertNote(Note note) async {
    try {
      final db = await instance.database;
      final noteData = note.toDb();

      final id = await db.insert('notes', noteData);

      return note.copyWith(id: id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      orderBy: 'updated_at DESC',
    );
    return result.map((json) => Note.fromDb(json)).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromDb(maps.first);
    }
    return null;
  }

  Future<List<Note>> searchNotes(String? query, String? tag) async {
    final db = await instance.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND title LIKE ?';
      whereArgs.add('%$query%');
    }

    if (tag != null && tag.isNotEmpty) {
      whereClause += ' AND tags LIKE ?';
      whereArgs.add('%$tag%');
    }

    final result = await db.query(
      'notes',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'updated_at DESC',
    );

    return result.map((json) => Note.fromDb(json)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toDb(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> getUnsyncedNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((json) => Note.fromDb(json)).toList();
  }

  // Pending Operations (pour la file d'attente)

  Future<int> insertPendingOperation({
    required String operationType,
    required int noteId,
    required String noteData,
  }) async {
    final db = await instance.database;
    return await db.insert('pending_operations', {
      'operation_type': operationType,
      'note_id': noteId,
      'note_data': noteData,
      'created_at': DateTime.now().toIso8601String(),
      'retries': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await instance.database;
    return await db.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );
  }

  Future<int> deletePendingOperation(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> incrementRetries(int id) async {
    final db = await instance.database;
    return await db.rawUpdate(
      'UPDATE pending_operations SET retries = retries + 1 WHERE id = ?',
      [id],
    );
  }

  // Clear all data (logout)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('notes');
    await db.delete('pending_operations');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}