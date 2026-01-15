
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../widgets/categorias.dart';
import 'llistes_page.dart';
import 'perfil_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

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
              children: const [
                CategorySection(), //aqui llamamos a la parte de categorias
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),

      // barra de menu por abajo
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, //  catalog seleccionado
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu), //seleccionamos el icono de las 3 lineas
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // casita de abajo
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
        ],
        onTap: (index) { 
          if (index == 0) {
            // abrir llistes_page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LlistesPage(),
              ),
            );
          }
          if (index == 2) {
            // abrir perfil_page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PerfilPage(),
              ),
            );
          }
          print(index);},
      ),
    );
  }
}