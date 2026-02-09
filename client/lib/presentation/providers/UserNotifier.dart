import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/User.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Clase que gestiona el estado del usuario autenticado
class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User());

  // Método para guardar/actualizar los datos del usuario logueado
  void afegirUsuari(User u) {
    state =
        u; // ← cambia el estado → notifica a todos los widgets que lo escuchan
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
