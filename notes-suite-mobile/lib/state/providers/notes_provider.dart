import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/note.dart';
import '../../data/services/note_service.dart';
import '../../data/services/sync_service.dart';

/// Notes State
class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;
  final int unsyncedCount;

  NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
    this.unsyncedCount = 0,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
    int? unsyncedCount,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
    );
  }
}

/// Notes Notifier
class NotesNotifier extends StateNotifier<NotesState> {
  final NoteService _noteService;
  final SyncService _syncService;

  NotesNotifier(this._noteService, this._syncService) : super(NotesState()) {
    _initializeNotes();
  }

  // Initialisation avec sync
  Future<void> _initializeNotes() async {

    // D'abord charger depuis le cache local
    await loadNotes();

    // Puis sync avec le serveur en arrière-plan
    _syncWithServer();
  }

  // Sync avec le serveur (non bloquant)
  Future<void> _syncWithServer() async {
    try {

      // Sync pending operations
      await _syncService.syncPendingOperations();

      // Recharger les notes depuis le serveur
      final notes = await _noteService.getNotes();

      state = state.copyWith(notes: notes);

      await _updateSyncStatus();
    } catch (e) {
      // Ne pas bloquer l'app si le sync échoue
    }
  }

  // Load notes (My Notes)
  Future<void> loadNotes({
    String? query,
    String? tag,
    String? visibility,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notes = await _noteService.getNotes(
        query: query,
        tag: tag,
        visibility: visibility,
      );

      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load shared notes
  Future<List<Note>> loadSharedNotes({
    String? query,
    String? tag,
  }) async {
    try {
      return await _noteService.getSharedNotes(
        query: query,
        tag: tag,
      );
    } catch (e) {
      return [];
    }
  }

  // Get note by ID
  Future<Note?> getNoteById(int id) async {
    return await _noteService.getNoteById(id);
  }

  // Create note
  Future<bool> createNote({
    required String title,
    required String contentMd,
    List<String> tags = const [],
  }) async {
    try {
      final note = await _noteService.createNote(
        title: title,
        contentMd: contentMd,
        tags: tags,
        // ❌ PAS de visibility ici
      );

      // Add to local state
      state = state.copyWith(
        notes: [note, ...state.notes],
      );

      await _updateSyncStatus();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update note
  Future<bool> updateNote({
    required int id,
    required String title,
    required String contentMd,
    List<String> tags = const [],
    Visibility? visibility, // ✅ Optionnel pour UPDATE
  }) async {
    try {
      final updatedNote = await _noteService.updateNote(
        id: id,
        title: title,
        contentMd: contentMd,
        tags: tags,
        visibility: visibility!, // ✅ Peut être modifié ici
      );

      // Update in local state
      final updatedNotes = state.notes.map((note) {
        return note.id == id ? updatedNote : note;
      }).toList();

      state = state.copyWith(notes: updatedNotes);
      await _updateSyncStatus();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Delete note
  Future<bool> deleteNote(int id) async {
    try {
      await _noteService.deleteNote(id);

      // Remove from local state
      final updatedNotes = state.notes.where((note) => note.id != id).toList();
      state = state.copyWith(notes: updatedNotes);

      await _updateSyncStatus();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Refresh (pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);

    try {

      // Sync pending operations
      await _syncService.manualSync();

      // Recharger depuis le serveur (force online)
      final notes = await _noteService.getNotes();

      state = state.copyWith(
        notes: notes,
        isRefreshing: false,
      );

    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  // Update sync status
  Future<void> _updateSyncStatus() async {
    final syncStatus = await _syncService.getSyncStatus();
    state = state.copyWith(
      unsyncedCount: syncStatus['unsyncedCount'] as int,
    );
  }

  // Share note with user
  Future<bool> shareNoteWithUser(int noteId, String email) async {
    try {
      await _noteService.shareNoteWithUser(noteId, email);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Create public link
  Future<String?> createPublicLink(int noteId) async {
    try {
      return await _noteService.createPublicLink(noteId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider
final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier(NoteService.instance, SyncService.instance);
});