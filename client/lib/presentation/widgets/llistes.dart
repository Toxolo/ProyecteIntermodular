import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'image_card.dart';

// Sección que muestra todas las listas del usuario
class LlistesSection extends StatelessWidget {
  final AppDatabase db;

  const LlistesSection({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder que carga todas las listas desde la base de datos local
    return FutureBuilder<List<VideoList>>(
      future: db.listsDao.getAllLists(),
      builder: (context, snapshot) {
        // Mientras carga → muestra spinner centrado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si no hay datos o la lista está vacía → mensaje informativo
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No tens cap llista',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final lists = snapshot.data!;

        // Mostramos cada lista como una sección vertical
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lists.map((list) {
            return Column(
              children: [
                _SingleCategory(db: db, list: list),
                const SizedBox(height: 20), // separación entre listas
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

// Widget interno que representa UNA sola lista: título + carrusel horizontal de vídeos
class _SingleCategory extends StatelessWidget {
  final AppDatabase db;
  final VideoList list;

  const _SingleCategory({required this.db, required this.list});

  @override
  Widget build(BuildContext context) {
    // Instancia singleton del servicio API
    final api = ApiService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la lista (ej: "Favoritos", "Para ver después")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(list.name, style: CatalogStyles.sectionTitle),
        ),
        const SizedBox(height: 10),

        // Carrusel horizontal de miniaturas (altura fija)
        SizedBox(
          height: 170,
          child: FutureBuilder<List<VideoListItem>>(
            // Cargamos los IDs de vídeos que pertenecen a esta lista
            future: db.listsDao.getVideosInList(list.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Llista buida',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              final items = snapshot.data!;

              // Lista horizontal scrollable
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final videoId = items[index].videoId;

                  // Para cada vídeo → cargamos sus detalles desde la API
                  return FutureBuilder<dynamic>(
                    future: api.getVideoById(videoId),
                    builder: (context, videoSnap) {
                      // Mientras carga el detalle → pequeño spinner en el tamaño de la tarjeta
                      if (videoSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 240,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      // Si no hay datos → no mostramos nada (evitamos errores)
                      if (!videoSnap.hasData) {
                        return const SizedBox.shrink();
                      }

                      // Convertimos JSON → entidad Video
                      final video = VideoMapper.fromJson(videoSnap.data);

                      // Tarjeta reutilizable con miniatura + título superpuesto
                      return ImageCard(video: video, db: db);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
