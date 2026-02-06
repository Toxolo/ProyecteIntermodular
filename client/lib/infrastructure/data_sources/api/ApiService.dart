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

  // ──── Helper to get token (used by all requests) ────────────────────────────────
  String? _getAuthToken(Ref ref) {
    final user = ref.read(userProvider);
    final token = user.getAccesToken();
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Refresh token - returns true if successful, false otherwise
  /// Refresh token - returns true if successful, false otherwise
  Future<bool> refreshToken() async {
    try {
      final user = _ref.read(userProvider);
      final refreshToken = user.getRefreshToken();
      final userId = user.getId();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Correct format with params wrapper and refreshToken (camelCase)
      final Map<String, dynamic> requestBody = {
        "params": {
          "user_id": userId,
          "refresh_token": refreshToken, // camelCase, not snake_case
        },
      };

      final String jsonBody = jsonEncode(requestBody);

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

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // Expected format: {"result": {"access_token": "..."}}
          final newAccessToken = data['result']?['access_token'] as String?;
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            _ref.read(userProvider).setAccesToken(newAccessToken);
            return true;
          } else {
            return false;
          }
        } catch (parseError) {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
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

  // ──── CATEGORIES ────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getCategories() async {
    final token = _getAuthToken(_ref);
    final uri = Uri.parse('$_urlBase/Category');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final json = jsonDecode(body);
        return json is List ? json : [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ──── SERIES ────────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getSeries() async {
    final token = _getAuthToken(_ref);
    final uri = Uri.parse('$_urlBase/Serie');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final json = jsonDecode(body);
        return json is List ? json : [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtiene una serie por su ID
  Future<dynamic> getSerieById(int serieId) async {
    final series = await getSeries();

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

  // ──── VIDEOS / CATALEG ──────────────────────────────────────────────────────────
  Future<List<dynamic>> getVideos() async {
    final token = _getAuthToken(_ref);
    final uri = Uri.parse('$_urlBase/Cataleg');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final json = jsonDecode(body);

        if (json is List) {
          return json;
        } else if (json is Map) {
          // Handle common wrapped responses
          final list = json['data'] ?? json['results'] ?? json['content'] ?? [];
          return list is List ? list : [];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ──── SINGLE VIDEO ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getVideoById(int id) async {
    final token = _getAuthToken(_ref);
    final uri = Uri.parse('$_urlBase/Cataleg/$id');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final json = jsonDecode(body);
        return json is Map<String, dynamic> ? json : null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
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
