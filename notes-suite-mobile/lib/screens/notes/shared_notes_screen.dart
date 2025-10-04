import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/providers/notes_provider.dart';
import '../../state/providers/auth_provider.dart';
import '../../widgets/note_card.dart';
import 'package:notes_suite_mobile/data/models/note.dart';

class SharedNotesScreen extends ConsumerStatefulWidget {
  const SharedNotesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends ConsumerState<SharedNotesScreen> {
  final _searchController = TextEditingController();
  String? _selectedTag;
  List<Note> _sharedNotes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSharedNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedNotes() async {
    setState(() => _isLoading = true);

    final notes = await ref.read(notesProvider.notifier).loadSharedNotes(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      tag: _selectedTag,
    );

    setState(() {
      _sharedNotes = notes;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _loadSharedNotes();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserEmail = authState.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared with Me'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSharedNotes,
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
                      hintText: 'Search shared notes...',
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
                  // Tag filter
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Tag',
                      hintText: 'Filter by tag',
                      prefixIcon: const Icon(Icons.label_outlined),
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
                ],
              ),
            ),

            // Shared notes list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _sharedNotes.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shared notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Notes shared with you will appear here',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _sharedNotes.length,
                itemBuilder: (context, index) {
                  final note = _sharedNotes[index];
                  final isOwner = note.ownerEmail == currentUserEmail;

                  return NoteCard(
                    note: note,
                    isOwner: isOwner,
                    onTap: () => context.push('/note/${note.id}'),
                    // Pas de onEdit/onDelete pour les notes partagées (READ only)
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}