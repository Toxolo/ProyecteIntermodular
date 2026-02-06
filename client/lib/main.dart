import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/presentation/providers/AppBootStrap.dart';
import 'package:client/presentation/screens/HomeScreen.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/presentation/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/config/GlobalVariables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // important per usar async al main

  // Forzar vertical por defecto
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final db = AppDatabase(); // crea la base de dades
  runApp(ProviderScope(child: AppBootstrap(db: db)));
}

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(db: db),
      },
    );
  }
}
