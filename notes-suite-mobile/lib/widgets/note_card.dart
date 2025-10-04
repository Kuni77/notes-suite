import 'package:flutter/material.dart' hide Visibility;
import 'package:notes_suite_mobile/data/models/note.dart';
import '../utils/date_formatter.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isOwner = true,
  }) : super(key: key);

  Color _getVisibilityColor() {
    switch (note.visibility) {
      case Visibility.PRIVATE:
        return AppTheme.privateColor;
      case Visibility.SHARED:
        return AppTheme.sharedColor;
      case Visibility.PUBLIC:
        return AppTheme.publicColor;
    }
  }

  Color _getVisibilityTextColor() {
    switch (note.visibility) {
      case Visibility.PRIVATE:
        return AppTheme.textSecondaryColor;
      case Visibility.SHARED:
        return Colors.blue.shade700;
      case Visibility.PUBLIC:
        return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Visibility badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getVisibilityColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.visibility.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getVisibilityTextColor(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Content preview
              Text(
                note.contentMd,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Tags
              if (note.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: note.tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              // Footer: Date + Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatRelative(note.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      // Sync indicator
                      if (!note.isSynced)
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 14,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Actions (Edit / Delete) only if owner
                  if (isOwner)
                    Row(
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: onEdit,
                            color: AppTheme.primaryColor,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 8),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: onDelete,
                            color: AppTheme.errorColor,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    )
                  else
                  // Read-only badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Read Only',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}