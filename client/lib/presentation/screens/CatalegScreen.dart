import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../widgets/seriesCategoria.dart';

// Pantalla principal del catálogo (donde se muestran categorías y series)
class CatalegScreen extends StatefulWidget {
  // Recibe la base de datos local para poder usarla en las secciones
  final AppDatabase db;

  const CatalegScreen({super.key, required this.db});

  @override
  State<CatalegScreen> createState() => _CatalegScreenState();
}

// Estado de la pantalla del catálogo
class _CatalegScreenState extends State<CatalegScreen> {
  // Acceso rápido a la base de datos desde el estado
  AppDatabase get db => widget.db;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo negro característico del catálogo
      backgroundColor: CatalogStyles.backgroundBlack,

      body: Column(
        children: [
          // Espacio superior pequeño
          const SizedBox(height: 10),

          // La parte principal ocupa todo el espacio restante
          Expanded(
            child: ListView(
              children: [
                // Sección que muestra las categorías
                CategorySection(db: db),

                // Espacio entre secciones para que no quede todo pegado
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
