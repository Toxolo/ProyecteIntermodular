import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/main.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget raíz que prepara / inicializa cosas importantes antes de mostrar la app
class AppBootstrap extends ConsumerWidget {
  // Recibimos la instancia de la base de datos
  final AppDatabase db;

  // Constructor → obliga a pasar la base de datos
  const AppBootstrap({super.key, required this.db});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Forzamos que se inicilize el provider para poder acceder mas tarde
    ref.watch(apiServiceProvider);

    return MyApp(db: db);
  }
}
