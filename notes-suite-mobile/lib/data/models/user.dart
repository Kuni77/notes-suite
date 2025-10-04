class User {
  final String email;
  final String? accessToken;
  final String? refreshToken;

  User({
    required this.email,
    this.accessToken,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }

  User copyWith({
    String? email,
    String? accessToken,
    String? refreshToken,
  }) {
    return User(
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['status'] == 200 || json['success'] == true;

    return AuthResponse(
      success: isSuccess,
      message: json['message'],
      accessToken: json['data']?['accessToken'],
      refreshToken: json['data']?['refreshToken'],
    );
  }
}