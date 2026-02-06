import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/User.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User());

  void afegirUsuari(User u) {
    state = u;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.init(ref, baseUrl);
});
