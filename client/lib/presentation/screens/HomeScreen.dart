import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'CatalegScreen.dart'; // Asegúrate de que la ruta sea correcta
import 'LlistesScreen.dart';
import 'PerfilScreen.dart';
import 'SearchScreen.dart'; // Importa SearchPage para la navegación

class HomeScreen extends StatefulWidget {
  final AppDatabase db;
  const HomeScreen({super.key, required this.db});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Empieza en CatalogPage (Home)
  AppDatabase get db => widget.db;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      LlistesScreen(db: db),
      CatalegScreen(db: db),
      PerfilScreen(db: db),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior fija con logo + búsqueda
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: [
              // Texto centrado horizontal y un poco más abajo
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 30), // ajusta este valor
                  child: Text(
                    'Padalustro',
                    style: TextStyle(
                      color: Color(0xFFCC7722),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Logo a la izquierda, centrado verticalmente un poco más abajo
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    top: 30,
                  ), // top ajusta vertical
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Botón de búsqueda a la derecha, centrado verticalmente un poco más abajo
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                  ), // top ajusta vertical
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Buscar series',
                    onPressed: () {
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

      // Contenido que cambia según la pestaña
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? Colors.transparent
                : Colors.white,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.normal
                : FontWeight.normal,
          );
        }),
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Personaliza colores si quieres (opcional)
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
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ), // Cambié a person para que sea más claro (perfil)
            selectedIcon: Icon(Icons.person_outline, color: Colors.white),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
