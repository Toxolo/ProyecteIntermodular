
import 'package:client/catalog/widgets/bottom_bar.dart';
import 'package:client/data/local/app_database.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../widgets/categorias.dart';


class CatalogPage extends StatelessWidget {
  final AppDatabase db;

  const CatalogPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack, //hacemos que el fondo sea negro

      // cabeza de la app con lo más nuevo (o lo que queramos)
      body: Column(
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('image.png'), fit: BoxFit.cover,),
                borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // el logo y el icono de búsqueda
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Color.fromRGBO(255, 255, 255, 1)), 
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Título del destacado o más nuevo',
                  style: CatalogStyles.headerTitle,
                ),
              ],
            ),
          ),

          //  catalogo
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                CategorySection(db: db,), //aqui llamamos a la parte de categorias
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),

      // barra de menu por abajo
      bottomNavigationBar: BottomBar(currentIndex: 1, db: db), // catalog

    );
  }
}