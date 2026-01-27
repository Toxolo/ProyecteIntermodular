import 'package:flutter/material.dart';
import '../pages/catalog_page.dart';
import '../pages/llistes_page.dart';
import '../pages/perfil_page.dart';
import 'package:client/data/local/app_database.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex; // 0 = llistes, 1 = catalog, 2 = perfil
  final AppDatabase db;

  const BottomBar({super.key, required this.currentIndex, required this.db});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.circle), label: ''),
      ],
      onTap: (index) {
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LlistesPage(db: db)),
          );
        }
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CatalogPage(db: db)),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PerfilPage(db: db)),
          );
        }
      },
    );
  }
}
