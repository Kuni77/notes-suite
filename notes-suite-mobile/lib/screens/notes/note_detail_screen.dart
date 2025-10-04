import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../state/providers/notes_provider.dart';
import '../../state/providers/auth_provider.dart';
import '../../data/models/note.dart';
import '../../utils/date_formatter.dart';
import '../../theme/app_theme.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final int noteId;

  const NoteDetailScreen({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  Note? _note;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    final note = await ref.read(notesProvider.notifier).getNoteById(widget.noteId);
    setState(() {
      _note = note;
      _isLoading = false;
    });
  }

  Future<void> _shareWithUser() async {
    final emailController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Note'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'User Email',
            hintText: 'user@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, emailController.text),
            child: const Text('Share'),
          ),
        ],
      ),
    );

    if (email != null && email.isNotEmpty) {
      final success = await ref.read(notesProvider.notifier).shareNoteWithUser(
        widget.noteId,
        email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Note shared with $email'
                : 'Failed to share note'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createPublicLink() async {
    final token = await ref.read(notesProvider.notifier).createPublicLink(widget.noteId);

    if (token != null && mounted) {
      final url = 'https://yourapp.com/p/$token';

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Public Link Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Anyone with this link can view the note:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
              child: const Text('Copy Link'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteNote() async {
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
      final success = await ref.read(notesProvider.notifier).deleteNote(widget.noteId);
      if (mounted && success) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Note not found'),
        ),
      );
    }

    final authState = ref.watch(authProvider);
    final isOwner = _note!.ownerEmail == authState.user?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          if (isOwner) ...[
            // Share button
            PopupMenuButton(
              icon: const Icon(Icons.share),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'user',
                  child: ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Share with user'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'public',
                  child: ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Create public link'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'user') {
                  _shareWithUser();
                } else if (value == 'public') {
                  _createPublicLink();
                }
              },
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/note/${widget.noteId}/edit'),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _note!.title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),

            // Metadata row
            Row(
              children: [
                // Visibility badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _note!.visibility == Visibility.PRIVATE
                        ? AppTheme.privateColor
                        : _note!.visibility == Visibility.SHARED
                        ? AppTheme.sharedColor
                        : AppTheme.publicColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _note!.visibility.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                // Date
                Text(
                  'Updated ${DateFormatter.formatRelative(_note!.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                // Read-only indicator
                if (!isOwner)
                  const Chip(
                    label: Text('Read Only'),
                    avatar: Icon(Icons.visibility, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags
            if (_note!.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _note!.tags.map((tag) {
                  return Chip(label: Text('#$tag'));
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Content (Markdown)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MarkdownBody(
                  data: _note!.contentMd,
                  selectable: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}