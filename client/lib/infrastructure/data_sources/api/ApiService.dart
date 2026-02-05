import 'dart:convert';
import 'dart:io';
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
  String urlBase;
  late final Dio _dio;

  // Singleton pattern
  static ApiService? _instance;

  // Private constructor
  ApiService._internal(this.urlBase) {
    _dio = Dio(
      BaseOptions(
        baseUrl: urlBase,
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
          final container = ProviderContainer(); // temporary if no context/ref
          final user = container.read(userProvider);
          container.dispose(); // clean up

          final token = user.getAccesToken();

          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },

        // Optional: global error handling (e.g. 401 → logout)
        onError: (DioException err, handler) {
          if (err.response?.statusCode == 401) {}
          handler.next(err);
        },
      ),
    );
  }

  // Factory constructor that returns the singleton instance
  factory ApiService(String urlBase) {
    _instance ??= ApiService._internal(urlBase);
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
  Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await _dio.get(path);
      if (response.statusCode == HttpStatus.ok) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      // You can log or handle specific errors here
      return [];
    }
  }

  // ==================== CATEGORIA API ====================

  Future<List<dynamic>> getCategories() => _getList('/Category');

  /*
  /// Devuelve la lista de categorías desde el backend
  Future<List<dynamic>> getCategories() async {
    String url = "$urlBase/Category";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON as List;
    } else {
      return [];
    }
  }
  */

  // ==================== SERIE API ====================

  Future<List<dynamic>> getSeries() => _getList('/Serie');

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

  /*
  /// Obtiene todas las series
  Future<List<dynamic>> getSeries() async {
    String url = "$urlBase/Serie";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON as List;
    } else {
      return [];
    }
  }
  */

  // ==================== VIDEO API ====================

  Future<List<dynamic>> getVideos() => _getList('/Cataleg');

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

  /*
  /// Obtiene todos los vídeos
  Future<List<dynamic>> getVideos() async {
    String url = "$urlBase/Cataleg";
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
    String url = "$urlBase/Cataleg/$id";
    http.Response data = await http.get(Uri.parse(url));
    if (data.statusCode == HttpStatus.ok) {
      String body = utf8.decode(data.bodyBytes);
      final bodyJSON = jsonDecode(body);
      return bodyJSON;
    } else {
      return null;
    }
  }
  */
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
