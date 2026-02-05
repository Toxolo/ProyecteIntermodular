import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/UserNotifier.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-backend.com/api',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // interceptar el missatge
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(userProvider).getAccesToken();

        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },

      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          // TODO
          // 1. Refresh Token
          // 2. No token
        }
        handler.next(err);
      },
    ),
  );

  return dio;
});
