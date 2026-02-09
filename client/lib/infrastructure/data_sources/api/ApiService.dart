import 'dart:convert';
import 'dart:io';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:client/infrastructure/data_sources/local/daos/lists_dao.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:path_provider/path_provider.dart';

// Clase principal para comunicarse con la API
class ApiService {
  String _urlBase; // Dirección base de la API (ej: https://api.ejemplo.com)
  late final Dio _dio; // Cliente HTTP avanzado (usamos Dio)
  late CookieJar _cookieJar; // Maneja y guarda cookies

  // Patrón Singleton → solo queremos UNA instancia de ApiService
  static ApiService? _instance;
  final Ref _ref; // Referencia a Riverpod para leer providers

  // Método recomendado para inicializar (se usa normalmente)
  static ApiService init(Ref ref, String urlBase) {
    _instance ??= ApiService._internal(ref, urlBase);
    return _instance!;
  }

  // Constructor factory (por compatibilidad)
  factory ApiService(Ref ref, String urlBase) {
    _instance ??= ApiService._internal(ref, urlBase);
    return _instance!;
  }

  // Constructor privado real
  ApiService._internal(this._ref, this._urlBase) {
    // Configuramos Dio con opciones básicas
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

    // Preparamos las cookies (se hace de forma asíncrona)
    _initCookies().then((_) {
      // Añadimos el manejador de cookies a Dio
      _dio.interceptors.add(CookieManager(_cookieJar));

      // Añadimos token de autorización automáticamente cuando existe
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
            // Aquí se podría manejar error 401 (token caducado) en el futuro
            handler.next(err);
          },
        ),
      );
    });
  }

  // Crea y configura el almacenamiento persistente de cookies
  Future<void> _initCookies() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';

    // Creamos la carpeta si no existe
    await Directory(cookiePath).create(recursive: true);

    // Guardamos cookies en disco → sobreviven al cerrar la app
    _cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
      ignoreExpires: false, // Respetamos fecha de caducidad
      persistSession: true, // Guardamos también cookies de sesión
    );
  }

  // Getter para acceder al cliente Dio desde fuera
  Dio get dio => _dio;

  // Obtiene el token actual del usuario (o null si no hay)
  String? _getAuthToken(Ref ref) {
    final user = ref.read(userProvider);
    final token = user.getAccesToken();
    return (token != null && token.isNotEmpty) ? token : null;
  }

  // Intenta renovar el access token usando el refresh token
  Future<bool> refreshToken() async {
    try {
      final user = _ref.read(userProvider);
      final refreshToken = user.getRefreshToken();
      final userId = user.getId();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Preparamos el cuerpo de la petición (formato esperado por el backend)
      final Map<String, dynamic> requestBody = {
        "params": {"user_id": userId, "refresh_token": refreshToken},
      };

      final response = await http
          .post(
            Uri.parse(refreshTokenUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['result']?['access_token'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          _ref.read(userProvider).setAccesToken(newAccessToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Asegura que las cookies estén inicializadas (útil al iniciar la app)
  Future<void> ensureCookiesInitialized() async {
    if (_cookieJar is! PersistCookieJar) {
      await _initCookies();
    }
  }

  // Forma segura de obtener la instancia ya creada
  static ApiService get instance {
    if (_instance == null) {
      throw Exception(
        'ApiService no inicializado. Llama primero a ApiService.init()',
      );
    }
    return _instance!;
  }

  // ──── CATEGORÍAS ────────────────────────────────────────────────────────────────

  // Obtiene la lista de todas las categorías
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
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ──── SERIES ────────────────────────────────────────────────────────────────────

  // Obtiene todas las series disponibles
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
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Busca una serie específica por su ID (busca en la lista completa)
  Future<dynamic> getSerieById(int serieId) async {
    final series = await getSeries();
    try {
      return series.firstWhere((s) => s['id'] == serieId);
    } catch (_) {
      return null;
    }
  }

  // Obtiene todos los vídeos de una serie y los ordena por temporada y capítulo
  Future<List<dynamic>> getVideosBySeries(int seriesId) async {
    final videos = await getVideos();
    final filtered = videos
        .where((v) => v['series']['id'] == seriesId)
        .toList();

    // Ordenamos: primero por temporada, luego por capítulo
    filtered.sort((a, b) {
      if (a['season'] != b['season']) return a['season'].compareTo(b['season']);
      return a['chapter'].compareTo(b['chapter']);
    });

    return filtered;
  }

  // ──── CATÁLOGO / VÍDEOS ─────────────────────────────────────────────────────────

  // Obtiene todo el catálogo de vídeos
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

        if (json is List) return json;

        // Algunos backends envuelven la lista en "data", "results", etc.
        final list = json['data'] ?? json['results'] ?? json['content'] ?? [];
        return list is List ? list : [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtiene los detalles de un vídeo concreto por su ID
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
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// Servicio para manejar listas locales (favoritos, para ver, etc.)
class VideoListService {
  final ListsDao _listsDao;

  VideoListService(this._listsDao);

  // Devuelve todas las listas creadas por el usuario
  Future<List<VideoList>> getAllLists() async {
    return await _listsDao.getAllLists();
  }

  // Crea una nueva lista con el nombre indicado
  Future<void> createList(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('El nombre de la lista no puede estar vacío');
    }
    await _listsDao.createList(name);
  }

  // Añade un vídeo a una lista (si no está ya)
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

  // Quita un vídeo de una lista (si existe)
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

  // Devuelve en qué listas está guardado un vídeo (para marcar checkboxes)
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

  // Elimina una lista completa
  Future<void> deleteList(int listId) async {
    await _listsDao.deleteList(listId);
  }
}
