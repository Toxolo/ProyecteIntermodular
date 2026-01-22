import 'package:client/data/local/app_database.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../widgets/llistes.dart';
import 'perfil_page.dart';

// import 'perfil_page.dart';


class LlistesPage extends StatelessWidget {
  final AppDatabase db; // <-- base de dades passada des del main

  const LlistesPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      body: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png', height: 40),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                LlistesSection(db: db), // <-- enviem la BD a la secció
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.circle), label: ''),
        ],
        onTap: (index) {
          if (index == 1) Navigator.pop(context);
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilPage(db: db,),
              ),
            );
          }
        },
      ),
    );
  }
}
