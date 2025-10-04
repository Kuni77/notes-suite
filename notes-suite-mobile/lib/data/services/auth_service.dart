import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final _api = ApiService.instance;
  final _storage = const FlutterSecureStorage();
  final _db = DatabaseHelper.instance;

  AuthService._init();

  // Register
  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await _api.register(email, password);
      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.accessToken != null) {
        await _saveTokens(
          authResponse.accessToken!,
          authResponse.refreshToken!,
        );
        await _storage.write(key: 'userEmail', value: email);
      }

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _api.login(email, password);
      print('responseeeee');
      print(response);
      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.accessToken != null) {
        await _saveTokens(
          authResponse.accessToken!,
          authResponse.refreshToken!,
        );
        await _storage.write(key: 'userEmail', value: email);
      }

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Save tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final email = await _storage.read(key: 'userEmail');
    final accessToken = await _storage.read(key: 'accessToken');
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (email == null || accessToken == null) {
      return null;
    }

    // Vérifier si le token est expiré
    if (JwtDecoder.isExpired(accessToken)) {
      return null;
    }

    return User(
      email: email,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: 'userEmail');
  }

  // Logout
  Future<void> logout() async {
    await _storage.deleteAll();
    await _db.clearAllData();
  }
}