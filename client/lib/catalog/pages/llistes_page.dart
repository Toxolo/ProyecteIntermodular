import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../widgets/llistes.dart';
import 'catalog_page.dart';
import 'perfil_page.dart';

// import 'perfil_page.dart';


class LlistesPage extends StatelessWidget {
  const LlistesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack, //hacemos que el fondo sea negro
      body: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
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
              ],
            ),
          ),

          //  catalogo
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                llistesSection(), //aqui llamamos a la parte de llistes
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),

      // barra de menu por abajo
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, //llistes seleccionado
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
          if (index == 1) {
            Navigator.pop(context);
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PerfilPage(),
              ),
            );
          }
        },
      ),
    );
  }
}