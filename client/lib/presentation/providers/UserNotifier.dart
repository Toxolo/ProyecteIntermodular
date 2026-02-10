import 'dart:async';

import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/User.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Clase que gestiona el estado del usuario autenticado
class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User());

  Timer? _tokenRefreshTimer;

  // Método para guardar/actualizar los datos del usuario logueado
  void afegirUsuari(User u) {
    state =
        u; // ← cambia el estado → notifica a todos los widgets que lo escuchan
  }

  /// Inicia la verificación automática de expiración de token cada 5 segundos
  void startTokenRefreshCheck() {
    _tokenRefreshTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      await refreshTokenIfNeeded();
    });
  }

  /// Detiene la verificación de token (llamar cuando el usuario cierre sesión)
  void stopTokenRefreshCheck() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Verifica si el token está a punto de expirar y lo refresca si es necesario
  Future<void> refreshTokenIfNeeded() async {
    state.onTokenExpirationWarning(() async {
      try {
        print("Token expiring soon, refreshing...");

        // Obtener el ApiService para hacer la llamada al backend
        final api = ApiService.instance;

        // Llamar al endpoint de refresh (ajusta según tu API)
        await api.refreshToken();

        // Calcular nueva fecha de expiración (1 minuto desde ahora)
        final newExpiration = DateTime.now().add(Duration(minutes: 1));

        // Actualizar el estado del usuario con el nuevo token
        state.setTokenExpiration(newExpiration);

        print("Token refreshed successfully");
      } catch (e) {
        print("Token refresh failed: $e");
        // Aquí puedes agregar lógica para cerrar sesión del usuario
        // por ejemplo: afegirUsuari(User()); // Limpia el usuario
      }
    });
  }
}

// Provider global del usuario
final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);

// Provider que crea e inicializa el ApiService (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  // Llamamos al método init() → fuerza la creación del singleton
  // y configura Dio + interceptores + cookies la primera vez
  return ApiService.init(ref, baseUrl);
  // Nota: baseUrl viene de GlobalVariables.dart
});
