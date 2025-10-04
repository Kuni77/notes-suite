enum Visibility { PRIVATE, SHARED, PUBLIC }

class Note {
  final int? id;
  final String title;
  final String contentMd;
  final List<String> tags;
  final Visibility visibility;
  final String ownerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Offline-first fields
  final bool isSynced;
  final String? localId;
  final String? pendingAction; // 'CREATE', 'UPDATE', 'DELETE'

  Note({
    this.id,
    required this.title,
    required this.contentMd,
    this.tags = const [],
    this.visibility = Visibility.PRIVATE,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
    this.localId,
    this.pendingAction,
  });

  // From JSON (API response)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      contentMd: json['contentMd'],
      tags: List<String>.from(json['tags'] ?? []),
      visibility: Visibility.values.firstWhere(
            (e) => e.name == json['visibility'],
        orElse: () => Visibility.PRIVATE,
      ),
      ownerEmail: json['ownerEmail'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: true,
    );
  }

  // To JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'contentMd': contentMd,
      'tags': tags,
      'visibility': visibility.name,
    };
  }

  // From Database (SQLite)
  factory Note.fromDb(Map<String, dynamic> db) {
    return Note(
      id: db['id'],
      title: db['title'],
      contentMd: db['content_md'],
      tags: db['tags'] != null
          ? (db['tags'] as String).split(',').where((t) => t.isNotEmpty).toList()
          : [],
      visibility: Visibility.values.firstWhere(
            (e) => e.name == db['visibility'],
        orElse: () => Visibility.PRIVATE,
      ),
      ownerEmail: db['owner_email'],
      createdAt: DateTime.parse(db['created_at']),
      updatedAt: DateTime.parse(db['updated_at']),
      isSynced: db['is_synced'] == 1,
      localId: db['local_id'],
      pendingAction: db['pending_action'],
    );
  }

  // To Database (SQLite)
  Map<String, dynamic> toDb() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content_md': contentMd,
      'tags': tags.join(','),
      'visibility': visibility.name,
      'owner_email': ownerEmail,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'local_id': localId,
      'pending_action': pendingAction,
    };
  }

  // Copy with
  Note copyWith({
    int? id,
    String? title,
    String? contentMd,
    List<String>? tags,
    Visibility? visibility,
    String? ownerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? localId,
    String? pendingAction,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentMd: contentMd ?? this.contentMd,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }
}