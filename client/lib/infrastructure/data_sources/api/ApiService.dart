import 'dart:convert';
import 'dart:io';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:client/presentation/screens/LoginScreen.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:client/infrastructure/data_sources/local/daos/lists_dao.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Unified API Service containing all remote and local data sources
class ApiService {
  String _urlBase;
  late final Dio _dio;
  late CookieJar _cookieJar;
  // Singleton pattern
  static ApiService? _instance;

  final Ref _ref;

  static ApiService init(Ref ref, String urlBase) {
    _instance ??= ApiService._internal(ref, urlBase);
    return _instance!;
  }

  factory ApiService(Ref ref, String urlBase) {
    _instance ??= ApiService._internal(ref, urlBase);
    return _instance!;
  }

  ApiService._internal(this._ref, this._urlBase) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _urlBase,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Initialize persistent cookie jar
    _initCookies().then((_) {
      // Add cookie manager AFTER jar is ready
      _dio.interceptors.add(CookieManager(_cookieJar));

      // Your token interceptor (keep if mixing token + cookies, or remove if pure cookies)
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final user = _ref.read(userProvider);
            final token = user.getAccesToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
          onError: (err, handler) {
            // Optional: handle 401 → auto refresh or logout
            handler.next(err);
          },
        ),
      );
    });
  }

  Future<void> _initCookies() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath =
        '${directory.path}/.cookies/'; // subfolder for organization

    // Create directory if needed
    await Directory(cookiePath).create(recursive: true);

    // Persistent jar: saves cookies to files → survives app restarts
    _cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
      ignoreExpires: false, // respect cookie expiration
      persistSession: true, // keep session cookies
    );

    // Optional: clear old cookies on init if needed (e.g. for logout)
    // await _cookieJar.deleteAll();
  }

  Dio get dio => _dio;

  /// Refresh token - returns true if successful, false otherwise
  /// Refresh token - returns true if successful, false otherwise
  Future<bool> refreshToken() async {
    try {
      final user = _ref.read(userProvider);
      final refreshToken = user.getRefreshToken();
      final userId = user.getId();

      print("\n🔐 === TOKEN REFRESH DEBUG START ===");
      print("User ID: $userId");
      print(
        "Refresh Token exists: ${refreshToken != null && refreshToken.isNotEmpty}",
      );
      print("Refresh Token length: ${refreshToken?.length}");

      if (refreshToken == null || refreshToken.isEmpty) {
        print("❌ No refresh token available");
        print("🔐 === TOKEN REFRESH DEBUG END ===\n");
        return false;
      }

      print("🔄 Attempting token refresh...");
      print("📍 Endpoint: $refreshTokenUrl");

      // Correct format with params wrapper and refreshToken (camelCase)
      final Map<String, dynamic> requestBody = {
        "params": {
          "user_id": userId,
          "refreshToken": refreshToken, // camelCase, not snake_case
        },
      };

      final String jsonBody = jsonEncode(requestBody);
      print("📤 Request body (string): $jsonBody");

      final response = await http
          .post(
            Uri.parse(refreshTokenUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      print("📊 Response status: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Got 200 response, parsing...");

        try {
          final data = jsonDecode(response.body);
          print("📋 Parsed JSON: $data");
          print("📋 Result field: ${data['result']}");

          // Expected format: {"result": {"access_token": "..."}}
          final newAccessToken = data['result']?['access_token'] as String?;

          print("🔑 Extracted token: ${newAccessToken?.substring(0, 20)}...");
          print("🔑 Token is null: ${newAccessToken == null}");
          print("🔑 Token is empty: ${newAccessToken?.isEmpty}");
          print("🔑 Token length: ${newAccessToken?.length}");

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            _ref.read(userProvider).setAccesToken(newAccessToken);
            print("✅ Token stored successfully");
            print("✅ Token refresh successful");
            print("🔐 === TOKEN REFRESH DEBUG END ===\n");
            return true;
          } else {
            print("⚠️ No valid access token in response");
            print("🔐 === TOKEN REFRESH DEBUG END ===\n");
            return false;
          }
        } catch (parseError) {
          print("❌ Error parsing response: $parseError");
          print("🔐 === TOKEN REFRESH DEBUG END ===\n");
          return false;
        }
      } else {
        print("❌ Token refresh failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        print("🔐 === TOKEN REFRESH DEBUG END ===\n");
        return false;
      }
    } catch (e) {
      print("❌ Token refresh exception: $e");
      print("Exception type: ${e.runtimeType}");
      print("🔐 === TOKEN REFRESH DEBUG END ===\n");
      return false;
    }
  }

  // Call this on app start or after login to ensure jar is loaded
  Future<void> ensureCookiesInitialized() async {
    if (_cookieJar is! PersistCookieJar) {
      await _initCookies();
    }
  }

  // Alternative: named constructor for getting the instance
  static ApiService get instance {
    if (_instance == null) {
      throw Exception(
        'ApiService not initialized. Call ApiService(urlBase) first.',
      );
    }
    return _instance!;
  }

  // ──── Helper: perform GET and return JSON list ────────────────────────────
  Future<List<dynamic>> _getList(String url, String path) async {
    try {
      final response = await _dio.get(url + path);
      if (response.statusCode == HttpStatus.ok) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      // ignore: avoid_print
      print(e);
      return [];
    }
  }

  // ==================== CATEGORIA API ====================

  //Future<List<dynamic>> getCategories() => _getList(baseUrl, '/Category');

  /// Devuelve la lista de categorías desde el backend
  Future<List<dynamic>> getCategories() async {
    String url = "$_urlBase/Category";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON as List;
    } else {
      return [];
    }
  }

  // ==================== SERIE API ====================

  //Future<List<dynamic>> getSeries() => _getList(baseUrl, '/Serie');

  /// Obtiene una serie por su ID
  Future<dynamic> getSerieById(int serieId) async {
    final series = await getSeries();

    // ignore: avoid_print
    print(series);

    try {
      return series.firstWhere((s) => s['id'] == serieId);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene todos los vídeos de una serie, ordenados por temporada y capítulo
  Future<List<dynamic>> getVideosBySeries(int seriesId) async {
    final videos = await getVideos();
    final filtered = videos
        .where((v) => v['series']['id'] == seriesId)
        .toList();

    filtered.sort((a, b) {
      if (a['season'] != b['season']) return a['season'].compareTo(b['season']);
      return a['chapter'].compareTo(b['chapter']);
    });

    return filtered;
  }

  /// Obtiene todas las series
  Future<List<dynamic>> getSeries() async {
    String url = "$_urlBase/Serie";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON as List;
    } else {
      return [];
    }
  }

  // ==================== VIDEO API ====================

  //// Future<List<dynamic>> getVideos() => _getList(baseUrl, '/Cataleg');
  /*
  Future<dynamic> getVideoById(int id) async {
    try {
      final response = await _dio.get('/Cataleg/$id');
      if (response.statusCode == HttpStatus.ok) {
        return response.data;
      }
      return null;
    } on DioException {
      return null;
    }
  }
*/
  /// Obtiene todos los vídeos
  Future<List<dynamic>> getVideos() async {
    String url = "$_urlBase/Cataleg";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON as List;
    } else {
      return [];
    }
  }

  /// Obtiene un vídeo por su ID
  Future<dynamic> getVideoById(int id) async {
    String url = "$_urlBase/Cataleg/$id";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON as Map<String, dynamic>?;
    } else {
      return [];
    }
  }
}

/// Service for managing video lists (local database operations)
class VideoListService {
  final ListsDao _listsDao;

  VideoListService(this._listsDao);

  /// Obtener todas las listas
  Future<List<VideoList>> getAllLists() async {
    return await _listsDao.getAllLists();
  }

  /// Crear nueva lista
  Future<void> createList(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('El nom de la llista no pot estar buit');
    }
    await _listsDao.createList(name);
  }

  /// Añadir un vídeo a una lista
  Future<void> addVideoToList({
    required int listId,
    required int videoId,
  }) async {
    final exists = await _listsDao.isVideoInList(
      listId: listId,
      videoId: videoId,
    );
    if (!exists) {
      await _listsDao.addVideoToList(listId: listId, videoId: videoId);
    }
  }

  /// Quitar un vídeo de una lista
  Future<void> removeVideoFromList({
    required int listId,
    required int videoId,
  }) async {
    final exists = await _listsDao.isVideoInList(
      listId: listId,
      videoId: videoId,
    );
    if (exists) {
      await _listsDao.removeVideoFromList(listId: listId, videoId: videoId);
    }
  }

  /// Obtener IDs de listas que contienen un vídeo (para checkboxes)
  Future<Set<int>> getListsContainingVideo(int videoId) async {
    final allLists = await _listsDao.getAllLists();
    final result = <int>{};
    for (var list in allLists) {
      final contains = await _listsDao.isVideoInList(
        listId: list.id,
        videoId: videoId,
      );
      if (contains) result.add(list.id);
    }
    return result;
  }

  /// Eliminar una lista
  Future<void> deleteList(int listId) async {
    await _listsDao.deleteList(listId);
  }
}
