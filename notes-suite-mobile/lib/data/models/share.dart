enum SharePermission { READ }

class Share {
  final int? id;
  final int noteId;
  final String sharedWithEmail;
  final SharePermission permission;
  final DateTime createdAt;

  Share({
    this.id,
    required this.noteId,
    required this.sharedWithEmail,
    this.permission = SharePermission.READ,
    required this.createdAt,
  });

  factory Share.fromJson(Map<String, dynamic> json) {
    return Share(
      id: json['id'],
      noteId: json['noteId'],
      sharedWithEmail: json['sharedWithEmail'],
      permission: SharePermission.values.firstWhere(
            (e) => e.name == json['permission'],
        orElse: () => SharePermission.READ,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': sharedWithEmail,
      'permission': permission.name,
    };
  }
}

class PublicLink {
  final int? id;
  final int noteId;
  final String urlToken;
  final DateTime? expiresAt;
  final DateTime createdAt;

  PublicLink({
    this.id,
    required this.noteId,
    required this.urlToken,
    this.expiresAt,
    required this.createdAt,
  });

  factory PublicLink.fromJson(Map<String, dynamic> json) {
    return PublicLink(
      id: json['id'],
      noteId: json['noteId'],
      urlToken: json['urlToken'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get publicUrl => 'https://yourapp.com/p/$urlToken';
}

// Request pour partager une note
class ShareNoteRequest {
  final String email;

  ShareNoteRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}