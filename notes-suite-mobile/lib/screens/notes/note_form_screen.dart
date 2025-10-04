import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../state/providers/notes_provider.dart';
import '../../data/models/note.dart';
import '../../utils/validators.dart';

class NoteFormScreen extends ConsumerStatefulWidget {
  final int? noteId; // null = create, non-null = edit

  const NoteFormScreen({
    Key? key,
    this.noteId,
  }) : super(key: key);

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  bool _isLoading = false;
  bool _showPreview = false;
  Visibility _selectedVisibility = Visibility.PRIVATE;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _loadNote();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);

    final note = await ref.read(notesProvider.notifier).getNoteById(widget.noteId!);

    if (note != null) {
      setState(() {
        _titleController.text = note.title;
        _contentController.text = note.contentMd;
        _selectedVisibility = note.visibility;
        _tags = List.from(note.tags);
        _isLoading = false;
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    print('note idddddddd');
    print(widget.noteId);

    final success = widget.noteId == null
        ? await ref.read(notesProvider.notifier).createNote(
      title: _titleController.text.trim(),
      contentMd: _contentController.text.trim(),
      tags: _tags,
    )
        : await ref.read(notesProvider.notifier).updateNote(
      id: widget.noteId!,
      title: _titleController.text.trim(),
      contentMd: _contentController.text.trim(),
      tags: _tags,
      visibility: _selectedVisibility,
    );
    print('successss creat note');
    print(success);
    setState(() => _isLoading = false);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.noteId == null
              ? 'Note created'
              : 'Note updated'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Create Note' : 'Edit Note'),
        actions: [
          // Preview toggle
          IconButton(
            icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
            onPressed: () => setState(() => _showPreview = !_showPreview),
            tooltip: _showPreview ? 'Edit' : 'Preview',
          ),
          // Save button
          TextButton(
            onPressed: _isLoading ? null : _saveNote,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: Validators.validateTitle,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Add Tag',
                        hintText: 'Enter tag and press +',
                        prefixIcon: Icon(Icons.label_outlined),
                      ),
                      enabled: !_isLoading,
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _isLoading ? null : _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tags display
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      onDeleted: _isLoading ? null : () => _removeTag(tag),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Content editor or preview
              if (_showPreview)
              // Markdown Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Divider(),
                        MarkdownBody(data: _contentController.text),
                      ],
                    ),
                  ),
                )
              else
              // Content editor
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content (Markdown supported)',
                    hintText: 'Write your note here...\n\n# Heading\n**bold** *italic*\n- list item',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 200),
                      child: Icon(Icons.notes),
                    ),
                  ),
                  maxLines: 15,
                  validator: Validators.validateContent,
                  enabled: !_isLoading,
                ),
              const SizedBox(height: 24),

              // Markdown help
              if (!_showPreview)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Markdown Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '# Heading | **bold** | *italic* | [link](url) | - list',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}