import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  // Base URL - Change selon environnement
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1'; // Android emulator
  // static const String baseUrl = 'http://localhost:8080/api/v1'; // iOS simulator

  ApiService._init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour ajouter le token JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Si 401 Unauthorized, tenter de refresh le token
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              // Retry la requête originale
              return handler.resolve(await _retry(error.requestOptions));
            } catch (e) {
              // Refresh failed, logout
              await _storage.deleteAll();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Refresh token
  Future<void> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) throw Exception('No refresh token');

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final newAccessToken = response.data['data']['accessToken'];
    final newRefreshToken = response.data['data']['refreshToken'];

    await _storage.write(key: 'accessToken', value: newAccessToken);
    await _storage.write(key: 'refreshToken', value: newRefreshToken);
  }

  // Retry request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Auth endpoints

  Future<Response> register(String email, String password) async {
    return await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> login(String email, String password) async {
    return await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  // Notes endpoints

  Future<Response> getNotes({
    String? query,
    String? tag,
    String? visibility,
    int page = 0,
    int size = 10,
  }) async {
    return await _dio.get(
      '/notes',
      queryParameters: {
        if (query != null) 'query': query,
        if (tag != null) 'tag': tag,
        if (visibility != null) 'visibility': visibility,
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> getSharedNotes({
    String? query,
    String? tag,
    int page = 0,
    int size = 10,
  }) async {
    return await _dio.get(
      '/notes/shared',
      queryParameters: {
        if (query != null) 'query': query,
        if (tag != null) 'tag': tag,
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> getNoteById(int id) async {
    return await _dio.get('/notes/$id');
  }

  Future<Response> createNote(Map<String, dynamic> data) async {
    return await _dio.post('/notes', data: data);
  }

  Future<Response> updateNote(int id, Map<String, dynamic> data) async {
    return await _dio.put('/notes/$id', data: data);
  }

  Future<Response> deleteNote(int id) async {
    return await _dio.delete('/notes/$id');
  }

  // Share endpoints

  Future<Response> shareNoteWithUser(int noteId, String email) async {
    return await _dio.post(
      '/notes/$noteId/share/user',
      data: {'email': email},
    );
  }

  Future<Response> createPublicLink(int noteId) async {
    return await _dio.post('/notes/$noteId/share/public');
  }

  Future<Response> getPublicNote(String token) async {
    return await _dio.get('/public/p/$token');
  }
}