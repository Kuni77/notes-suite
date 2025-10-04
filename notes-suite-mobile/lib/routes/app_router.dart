import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/notes/notes_list_screen.dart';
import '../screens/notes/note_detail_screen.dart';
import '../screens/notes/note_form_screen.dart';
import '../screens/notes/shared_notes_screen.dart';
import '../state/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Si non authentifié et pas sur login/register, rediriger vers login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Si authentifié et sur login/register, rediriger vers home
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Notes routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const NotesListScreen(),
      ),
      GoRoute(
        path: '/shared',
        name: 'shared',
        builder: (context, state) => const SharedNotesScreen(),
      ),
      GoRoute(
        path: '/note/new',
        name: 'noteNew',
        builder: (context, state) => const NoteFormScreen(),
      ),
      GoRoute(
        path: '/note/:id',
        name: 'noteDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return NoteDetailScreen(noteId: id);
        },
      ),
      GoRoute(
        path: '/note/:id/edit',
        name: 'noteEdit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return NoteFormScreen(noteId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});