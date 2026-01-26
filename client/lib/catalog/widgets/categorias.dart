import 'package:client/catalog/pages/vistaprev.dart';
import 'package:client/data/local/app_database.dart';
import 'package:client/services/Serie_service.dart';
import 'package:flutter/material.dart';

import 'package:client/models/video_mapper.dart';
import 'package:client/models/category.dart';
import 'package:client/models/serie_mapper.dart';
import 'package:client/services/video_service.dart';
import 'package:client/services/category_service.dart';

class CategorySection extends StatelessWidget {
  final AppDatabase db;

  const CategorySection({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          VideoService.getVideos(),
          SerieService.getCategories(),
          CategoryService.getCategories(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No hay datos',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final videos = snapshot.data![0] as List<Video>;
          final series = snapshot.data![1] as List<Serie>;
          final categories = snapshot.data![2] as List<Category>;

          // Map de id → nombre de categoría
          final Map<int, String> categoryMap = {
            for (final c in categories) c.id: c.name,
          };

          // Agrupar series por categorías de sus videos
          final Map<String, List<Map<String, dynamic>>> seriesByCategory = {};

          for (final serie in series) {
            // Obtenemos todos los videos de esta serie
            final serieVideos = videos.where((v) => v.series == serie.id).toList();

            if (serieVideos.isEmpty) continue;

            // Guardar la thumbnail del primer video en una variable local
            final firstThumbnail = serieVideos.first.thumbnail;

            // Recoger todas las categorías de los videos
            final Set<String> serieCategories = {};
            for (final v in serieVideos) {
              for (final catId in v.categorias) {
                serieCategories.add(categoryMap[catId] ?? 'Desconocida');
              }
            }

            // Añadir la serie a cada categoría correspondiente, junto con su thumbnail
            for (final catName in serieCategories) {
              seriesByCategory.putIfAbsent(catName, () => []);
              seriesByCategory[catName]!.add({
                'serie': serie,
                'thumbnail': firstThumbnail,
              });
            }
          }

          // Si no hay categorías, poner todas las series bajo "Todas"
          if (seriesByCategory.isEmpty) {
            seriesByCategory['Todas'] = series
                .map((s) => {
                      'serie': s,
                      'thumbnail': videos
                              .firstWhere((v) => v.series == s.id,
                                  orElse: () => videos.first)
                              .thumbnail,
                    })
                .toList();
          }

          // Construir la UI
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: seriesByCategory.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Título de la categoría
                  Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Thumbnails horizontales de series con overlay del nombre
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final serieMap = entry.value[index];
                        final serie = serieMap['serie'] as Serie;
                        final thumbnail = serieMap['thumbnail'] as String;

                        // Tomamos el primer video de la serie para abrir VistaPrev
                        final firstVideo = videos.firstWhere(
                            (v) => v.series == serie.id,
                            orElse: () => videos.first);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VistaPrev(
                                  videoId: firstVideo.id,
                                  db: db,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              children: [
                                // Imagen de fondo
                                Positioned.fill(
                                  child: Image.network(
                                    'http://10.0.2.2:3000/static/$thumbnail/thumbnail.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Si la primera falla, carga la segunda
                                      return Image.network(
                                        'https://ih1.redbubble.net/image.1861329650.2941/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),

                                ),
                                // Overlay negro semitransparente con nombre de la serie
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    color: Colors.black54,
                                    child: Text(
                                      serie.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
