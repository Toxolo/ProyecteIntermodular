import 'package:client/presentation/providers/AppBootStrap.dart';
import 'package:client/presentation/screens/HomeScreen.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/presentation/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Función main asíncrona (necesaria para inicializar cosas antes de runApp)
void main() async {
  // Asegura que Flutter esté listo para usar código asíncrono en main
  WidgetsFlutterBinding.ensureInitialized();

  // Forzamos orientación vertical (portrait) por defecto en toda la app
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Creamos la instancia de la base de datos local
  // (normalmente aquí se abre la conexión a Drift/Sqflite)
  final db = AppDatabase();

  // Ejecutamos la app envolviéndola en ProviderScope (Riverpod)
  // AppBootstrap se encarga de inicializar ApiService y pasar db a MyApp
  runApp(ProviderScope(child: AppBootstrap(db: db)));
}

// Widget raíz de la aplicación (MaterialApp)
class MyApp extends StatelessWidget {
  // Recibimos la base de datos desde AppBootstrap
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ocultamos el banner de debug en la esquina superior derecha
      debugShowCheckedModeBanner: false,

      // Ruta inicial: siempre empieza en la pantalla de login
      initialRoute: '/',

      // Definimos las rutas nombradas de la app
      routes: {
        // Pantalla de inicio de sesión (primera que ve el usuario)
        '/': (context) => LoginScreen(),

        // Pantalla principal con navegación inferior (catálogo, listas, perfil)
        '/home': (context) => HomeScreen(db: db),
      },
    );
  }
}
