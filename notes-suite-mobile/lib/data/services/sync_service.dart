import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';
import 'note_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  final _db = DatabaseHelper.instance;
  final _noteService = NoteService.instance;
  final _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;

  SyncService._init();

  // Start listening to connectivity changes
  void startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          // Network reconnected, sync pending operations
          syncPendingOperations();
        }
      },
    );

    // Periodic sync every 5 minutes
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
          (timer) => syncPendingOperations(),
    );
  }

  // Stop listening
  void stopListening() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
  }

  // Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return; // Avoid concurrent syncs

    _isSyncing = true;

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection, skipping sync');
        return;
      }

      print('Starting sync of pending operations...');

      final pendingOps = await _db.getPendingOperations();
      print('Found ${pendingOps.length} pending operations');

      for (var op in pendingOps) {
        try {
          await _syncOperation(op);
          // Remove from pending queue after successful sync
          await _db.deletePendingOperation(op['id'] as int);
          print('Synced operation ${op['id']}');
        } catch (e) {
          print('Error syncing operation ${op['id']}: $e');

          // Increment retry counter
          await _db.incrementRetries(op['id'] as int);

          // Delete if too many retries (max 5)
          final retries = op['retries'] as int;
          if (retries >= 5) {
            print('Max retries reached for operation ${op['id']}, removing');
            await _db.deletePendingOperation(op['id'] as int);
          }
        }
      }

      print('Sync completed');
    } finally {
      _isSyncing = false;
    }
  }

  // Sync a single operation
  Future<void> _syncOperation(Map<String, dynamic> op) async {
    final operationType = op['operation_type'] as String;
    final noteId = op['note_id'] as int;

    switch (operationType) {
      case 'CREATE':
        await _syncCreate(noteId);
        break;
      case 'UPDATE':
        await _syncUpdate(noteId);
        break;
      case 'DELETE':
        await _syncDelete(noteId);
        break;
    }
  }

  // Sync CREATE operation
  Future<void> _syncCreate(int localNoteId) async {
    final note = await _db.getNoteById(localNoteId);
    if (note == null) return;

    // Create on server
    final response = await _noteService.createNote(
      title: note.title,
      contentMd: note.contentMd,
      tags: note.tags,
    );

    // Update local note with server ID and mark as synced
    if (response.id != null) {
      await _db.updateNote(note.copyWith(
        id: response.id,
        isSynced: true,
        pendingAction: null,
      ));
    }
  }

  // Sync UPDATE operation
  Future<void> _syncUpdate(int noteId) async {
    final note = await _db.getNoteById(noteId);
    if (note == null || note.id == null) return;

    // Update on server
    await _noteService.updateNote(
      id: note.id!,
      title: note.title,
      contentMd: note.contentMd,
      tags: note.tags,
      visibility: note.visibility,
    );

    // Mark as synced
    await _db.updateNote(note.copyWith(
      isSynced: true,
      pendingAction: null,
    ));
  }

  // Sync DELETE operation
  Future<void> _syncDelete(int noteId) async {
    // Delete on server
    await _noteService.deleteNote(noteId);

    // Delete from local DB
    await _db.deleteNote(noteId);
  }

  // Manual sync trigger (pull-to-refresh)
  Future<void> manualSync() async {
    await syncPendingOperations();
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedNotes = await _noteService.getUnsyncedNotes();
    final pendingOps = await _db.getPendingOperations();

    return {
      'unsyncedCount': unsyncedNotes.length,
      'pendingOpsCount': pendingOps.length,
      'isSyncing': _isSyncing,
    };
  }
}