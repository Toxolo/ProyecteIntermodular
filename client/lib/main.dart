import 'package:client/infrastructure/data_sources/ApiService.dart';
import 'package:client/presentation/screens/HomeScreen.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // important per usar async al main

  final api = ApiService('http://10.0.2.2:8090');

  // Forzar vertical por defecto
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final db = AppDatabase(); // crea la base de dades
  runApp(MyApp(db: db)); // passem la instància a MyApp
}

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(db: db), // passem la db a CatalogPage
    );
  }
}
