import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start sync service listener
  SyncService.instance.startListening();

  runApp(
    const ProviderScope(
      child: NotesApp(),
    ),
  );
}