import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'database_helper.dart';
import 'auth_service.dart';

class NoteService {
  static final NoteService instance = NoteService._init();
  final _api = ApiService.instance;
  final _db = DatabaseHelper.instance;
  final _auth = AuthService.instance;
  final _connectivity = Connectivity();

  NoteService._init();

  // Check network connectivity
  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get Notes (My Notes)
  Future<List<Note>> getNotes({
    String? query,
    String? tag,
    String? visibility,
    int page = 0,
    int size = 10,
  }) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        final response = await _api.dio.get(
          '/notes',
          queryParameters: {
            if (query != null && query.isNotEmpty) 'query': query,
            if (tag != null && tag.isNotEmpty) 'tag': tag,
            if (visibility != null && visibility.isNotEmpty) 'visibility': visibility,
            'page': page,
            'size': size,
          },
        );


        // Le backend retourne {status: 200, data: [...], message: "..."}
        final responseData = response.data;

        if (responseData['data'] != null && responseData['data'] is List) {
          final notes = (responseData['data'] as List)
              .map((json) => Note.fromJson(json as Map<String, dynamic>))
              .toList();


          // Save to local DB
          for (var note in notes) {
            final existing = await _db.getNoteById(note.id!);
            if (existing != null) {
              await _db.updateNote(note);
            } else {
              await _db.insertNote(note);
            }
          }

          return notes;
        } else {
        }
      } catch (e) {
      }
    }

    return await _db.searchNotes(query, tag);
  }

  // Get Shared Notes
  Future<List<Note>> getSharedNotes({
    String? query,
    String? tag,
    int page = 0,
    int size = 10,
  }) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        final response = await _api.dio.get(
          '/notes/shared',
          queryParameters: {
            if (query != null) 'query': query,
            if (tag != null) 'tag': tag,
            'page': page,
            'size': size,
          },
        );


        final responseData = response.data;

        if (responseData['data'] != null && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((json) => Note.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
      }
    }

    return [];
  }

  // Get Note by ID
  Future<Note?> getNoteById(int id) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        final response = await _api.dio.get('/notes/$id');
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
              (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final note = Note.fromJson(apiResponse.data!);

          // Save to local DB
          final existing = await _db.getNoteById(note.id!);
          if (existing != null) {
            await _db.updateNote(note);
          } else {
            await _db.insertNote(note);
          }

          return note;
        }
      } catch (e) {
      }
    }

    // Fallback to local DB
    return await _db.getNoteById(id);
  }

  // Create Note (Offline-first)
  Future<Note> createNote({
    required String title,
    required String contentMd,
    List<String> tags = const [],
  }) async {
    final userEmail = await _auth.getUserEmail() ?? 'unknown@email.com';
    final now = DateTime.now();

    final note = Note(
      title: title,
      contentMd: contentMd,
      tags: tags,
      visibility: Visibility.PRIVATE, // Par défaut pour le cache local
      ownerEmail: userEmail,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      localId: const Uuid().v4(),
      pendingAction: 'CREATE',
    );

    // Save to local DB first (offline-first)
    final savedNote = await _db.insertNote(note);

    // Add to pending operations queue
    final pendingOpId = await _db.insertPendingOperation(
      operationType: 'CREATE',
      noteId: savedNote.id!,
      noteData: jsonEncode({
        'title': title,
        'contentMd': contentMd,
        'tags': tags,
      }),
    );

    // Try to sync immediately if online
    final isOnline = await _isOnline();
    if (isOnline) {
      await _syncNote(savedNote);
      // Supprimer l'opération pending après sync réussi
      await _db.deletePendingOperation(pendingOpId);
    }

    return savedNote;
  }

  // Update Note (Offline-first)
  Future<Note> updateNote({
    required int id,
    required String title,
    required String contentMd,
    List<String> tags = const [],
    Visibility visibility = Visibility.PRIVATE,
  }) async {
    final existingNote = await _db.getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note not found');
    }

    final updatedNote = existingNote.copyWith(
      title: title,
      contentMd: contentMd,
      tags: tags,
      visibility: visibility,
      updatedAt: DateTime.now(),
      isSynced: false,
      pendingAction: 'UPDATE',
    );

    // Update in local DB
    await _db.updateNote(updatedNote);

    // Add to pending operations queue
    await _db.insertPendingOperation(
      operationType: 'UPDATE',
      noteId: id,
      noteData: jsonEncode(updatedNote.toJson()),
    );

    // Try to sync immediately if online
    final isOnline = await _isOnline();
    if (isOnline) {
      await _syncNote(updatedNote);
    }

    return updatedNote;
  }

  // Delete Note (Offline-first)
  Future<void> deleteNote(int id) async {
    final note = await _db.getNoteById(id);
    if (note == null) return;

    // Mark as pending delete
    final updatedNote = note.copyWith(
      isSynced: false,
      pendingAction: 'DELETE',
    );
    await _db.updateNote(updatedNote);

    // Add to pending operations
    await _db.insertPendingOperation(
      operationType: 'DELETE',
      noteId: id,
      noteData: jsonEncode({'id': id}),
    );

    // Try to sync immediately if online
    final isOnline = await _isOnline();
    if (isOnline) {
      await _syncDeletedNote(id);
    } else {
      // Si offline, on garde la note en local jusqu'à sync
    }
  }

  // Sync a single note
  Future<void> _syncNote(Note note) async {
    try {
      if (note.pendingAction == 'CREATE') {
        // Pour CREATE : utiliser toJson() (sans visibility)
        final response = await _api.dio.post('/notes', data: note.toJson());

        // Le backend retourne "status": 201 au lieu de "success": true
        final isSuccess = response.data['status'] == 201 || response.data['status'] == 200;

        if (isSuccess && response.data['data'] != null) {
          final serverNote = Note.fromJson(response.data['data']);

          // ⚠️ IMPORTANT: Mettre à jour la note LOCALE avec l'ID serveur
          // On supprime l'ancienne note locale et on insère la nouvelle
          await _db.deleteNote(note.id!); // Supprimer l'ancienne (id local)

          final syncedNote = serverNote.copyWith(
            isSynced: true,
            pendingAction: null,
            localId: null,
          );

          await _db.insertNote(syncedNote); // Insérer avec l'ID serveur
        }
      } else if (note.pendingAction == 'UPDATE' && note.id != null) {
        // Pour UPDATE : utiliser toUpdateJson() (avec visibility)
        await _api.dio.put('/notes/${note.id}', data: note.toUpdateJson());

        // Mark as synced
        await _db.updateNote(note.copyWith(
          isSynced: true,
          pendingAction: null,
        ));
      }
    } catch (e) {
      // Keep in pending queue
    }
  }

  // Sync deleted note
  Future<void> _syncDeletedNote(int id) async {
    try {
      await _api.dio.delete('/notes/$id');
      // Delete from local DB
      await _db.deleteNote(id);
    } catch (e) {
    }
  }

  // Get unsynced notes
  Future<List<Note>> getUnsyncedNotes() async {
    return await _db.getUnsyncedNotes();
  }

  // Share note with user
  Future<void> shareNoteWithUser(int noteId, String email) async {
    await _api.dio.post('/notes/$noteId/share/user', data: {'email': email});
  }

  // Create public link
  Future<String> createPublicLink(int noteId) async {
    final response = await _api.dio.post('/notes/$noteId/share/public');
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
          (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!['urlToken'] as String;
    }

    throw Exception('Failed to create public link');
  }
}