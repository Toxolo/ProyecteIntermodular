import 'dart:convert';
import 'dart:io';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:client/infrastructure/data_sources/local/daos/lists_dao.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';


/// Unified API Service containing all remote and local data sources
class ApiService {
  String _urlBase;
  late final Dio _dio;
  // Singleton pattern
  static ApiService? _instance;

  final Ref _ref;

  static ApiService init(Ref ref, String urlBase) {
    _instance ??= ApiService._internal(ref, urlBase);
    return _instance!;
  }

  // Private constructor
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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final user = _ref.read(userProvider);
          final token = user.getAccesToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // else: no token, proceed without Authorization
          handler.next(options);
        },
        onError: (err, handler) {
          // handle 401 globally
          handler.next(err);
        },
      ),
    );
  }

  // Factory constructor that returns the singleton instance
  factory ApiService(Ref ref, String URL) {
    _instance ??= ApiService._internal(ref, URL);
    return _instance!;
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

  // ── Helper: perform GET and return JSON list ───────────────────────────────
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

  Future<Map<String, dynamic>?> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        print("No hay refresh token disponible");
        return null;
      }

      final response = await http.post(
        Uri.parse(
          '$baseUrl/auth/refresh',
        ), // ← ajusta esta ruta a tu endpoint real
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Suponiendo que tu backend devuelve algo como:
        // { "access_token": "...", "refresh_token": "..." (opcional) }
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken == null) {
          print("No se recibió access_token en la respuesta");
          return null;
        }

        // Opcional: actualizar refresh_token si el backend envía uno nuevo
        if (newRefreshToken != null) {
          await storage.write(key: 'refresh_token', value: newRefreshToken);
        }

        return {
          'access_token': newAccessToken,
          'refresh_token': newRefreshToken ?? refreshToken,
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print("Refresh token inválido o expirado: ${response.body}");
        // Aquí podrías limpiar tokens y forzar logout
        return null;
      } else {
        print("Error en refresh: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Excepción al refrescar token: $e");
      return null;
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
