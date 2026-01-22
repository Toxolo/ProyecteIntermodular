import 'package:client/data/local/app_database.dart';
import 'package:flutter/material.dart';
import 'catalog/pages/catalog_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // important per usar async al main
  final db = AppDatabase(); // crea la base de dades
  runApp(MyApp(db: db));   // passem la instància a MyApp
}

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CatalogPage(db: db), // passem la db a CatalogPage
    );
  }
}
