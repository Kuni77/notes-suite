import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/providers/notes_provider.dart';
import '../../state/providers/auth_provider.dart';
import '../../widgets/note_card.dart';
import '../../data/models/note.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  final _searchController = TextEditingController();
  String? _selectedVisibility;
  String? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(notesProvider.notifier).loadNotes(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      visibility: _selectedVisibility, // Déjà une String ou null
      tag: _selectedTag,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedVisibility = null;
      _selectedTag = null;
    });
    ref.read(notesProvider.notifier).loadNotes();
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(notesProvider.notifier).deleteNote(id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final authState = ref.watch(authProvider);
    final currentUserEmail = authState.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          // Sync indicator
          if (notesState.unsyncedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Chip(
                  label: Text('${notesState.unsyncedCount} pending'),
                  avatar: const Icon(Icons.cloud_off, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          // Shared notes button
          IconButton(
            icon: const Icon(Icons.people_outlined),
            onPressed: () => context.push('/shared'),
            tooltip: 'Shared with me',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notesProvider.notifier).refresh(),
        child: Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                          : null,
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                  const SizedBox(height: 12),
                  // Visibility & Tag filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedVisibility,
                          decoration: const InputDecoration(
                            labelText: 'Visibility',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
                            DropdownMenuItem(
                              value: 'PRIVATE',
                              child: Text('Private'),
                            ),
                            DropdownMenuItem(
                              value: 'SHARED',
                              child: Text('Shared'),
                            ),
                            DropdownMenuItem(
                              value: 'PUBLIC',
                              child: Text('Public'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedVisibility = value);
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Tag',
                            hintText: 'Filter by tag',
                            suffixIcon: _selectedTag != null
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _selectedTag = null);
                                _applyFilters();
                              },
                            )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() => _selectedTag = value.isEmpty ? null : value);
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notes list
            Expanded(
              child: notesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notesState.notes.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notes found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first note!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: notesState.notes.length,
                itemBuilder: (context, index) {
                  final note = notesState.notes[index];
                  final isOwner = note.ownerEmail == currentUserEmail;

                  return NoteCard(
                    note: note,
                    isOwner: isOwner,
                    onTap: () => context.push('/note/${note.id}'),
                    onEdit: isOwner
                        ? () => context.push('/note/${note.id}/edit')
                        : null,
                    onDelete: isOwner
                        ? () => _handleDelete(note.id!)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/note/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}