import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'CatalegScreen.dart'; // Asegúrate de que la ruta sea correcta
import 'LlistesScreen.dart';
import 'PerfilScreen.dart';
import 'SearchScreen.dart'; // Importa SearchPage para la navegación

// Pantalla principal de la aplicación (Home)
// Contiene la barra superior personalizada + navegación inferior
class HomeScreen extends StatefulWidget {
  // Recibe la base de datos para pasarla a todas las pantallas hijas
  final AppDatabase db;

  const HomeScreen({super.key, required this.db});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice de la pestaña seleccionada actualmente
  // Empieza en 1 → Home / Catálogo (índice 0 = Listas, 1 = Home, 2 = Perfil)
  int _currentIndex = 1;

  // Acceso rápido a la base de datos
  AppDatabase get db => widget.db;

  // Lista de pantallas que se van a mostrar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Creamos las 3 pantallas principales una sola vez
    // y las mantenemos vivas gracias a IndexedStack
    _pages = [
      LlistesScreen(db: db), // 0 → Mis listas
      CatalegScreen(db: db), // 1 → Catálogo principal (Home)
      PerfilScreen(db: db), // 2 → Perfil del usuario
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior personalizada
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0,
          automaticallyImplyLeading: false, // quita la flecha de atrás
          // Usamos flexibleSpace + Stack para superponer logo, título y búsqueda
          flexibleSpace: Stack(
            children: [
              // Nombre de la app centrado
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Padalustro',
                    style: TextStyle(
                      color: Color(0xFFCC7722), // color corporativo
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Logo a la izquierda
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 30),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Botón de búsqueda a la derecha
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Buscar series',
                    onPressed: () {
                      // Navega a la pantalla de búsqueda
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(db: db),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Contenido principal: muestra la página seleccionada
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Barra de navegación inferior
      bottomNavigationBar: NavigationBar(
        // Oculta el texto de la pestaña seleccionada
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? Colors.transparent
                : Colors.white,
            fontWeight: FontWeight.normal,
          );
        }),

        // Pestaña actual
        selectedIndex: _currentIndex,

        // Cambia de pestaña al tocar
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // Color del indicador de selección
        indicatorColor: Color(0xFFCC7722),
        backgroundColor: Colors.black87,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu, color: Colors.white),
            selectedIcon: Icon(Icons.menu_open_outlined, color: Colors.white),
            label: 'Listas',
          ),
          NavigationDestination(
            icon: Icon(Icons.home, color: Colors.white),
            selectedIcon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Colors.white),
            selectedIcon: Icon(Icons.person_outline, color: Colors.white),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
