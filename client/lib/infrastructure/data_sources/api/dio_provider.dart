import 'package:client/config/GlobalVariables.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/UserNotifier.dart';

// Provider de Riverpod que crea y configura una instancia de Dio
// para hacer peticiones HTTP a la API
final dioProvider = Provider<Dio>((ref) {
  // Creamos la instancia de Dio con configuración básica
  final dio = Dio(
    BaseOptions(
      // URL base de la API (viene de GlobalVariables)
      baseUrl: expressUrl,

      // Tiempo máximo para conectar con el servidor
      connectTimeout: const Duration(seconds: 12),

      // Tiempo máximo para recibir la respuesta
      receiveTimeout: const Duration(seconds: 12),

      // Cabeceras por defecto en todas las peticiones
      headers: {
        'Accept': 'application/json', // Esperamos respuestas en JSON
        'Content-Type': 'application/json', // Enviamos datos en JSON
      },
    ),
  );

  // Añadimos interceptores para modificar las peticiones y respuestas
  dio.interceptors.add(
    InterceptorsWrapper(
      // Se ejecuta antes de enviar cada petición
      onRequest: (options, handler) {
        // Obtenemos el token del provider de usuario
        final token = ref.read(userProvider).getAccesToken();

        // Si existe token válido → lo añadimos al header Authorization
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Continuamos con la petición (muy importante)
        handler.next(options);
      },

      // Se ejecuta cuando hay un error en la petición
      onError: (DioException err, handler) async {
        // Si el error es 401 (no autorizado / token inválido o caducado)
        if (err.response?.statusCode == 401) {}

        // Continuamos propagando el error al código que hizo la petición
        handler.next(err);
      },
    ),
  );

  // Devolvemos la instancia de Dio ya configurada
  return dio;
});
