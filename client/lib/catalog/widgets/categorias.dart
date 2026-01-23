import 'package:client/data/local/app_database.dart';
import 'package:flutter/material.dart';

import 'package:client/models/video_mapper.dart';
import 'package:client/models/category.dart';
import 'package:client/services/video_service.dart';
import 'package:client/services/category_service.dart';

import 'image_card.dart';

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
          final categories = snapshot.data![1] as List<Category>;

          // Map de id → nombre de categoría
          final Map<int, String> categoryMap = {
            for (final c in categories) c.id: c.name,
          };

          // Agrupar vídeos por categoría
          final Map<String, List<Video>> videosByCategory = {};

          for (final video in videos) {
            for (final catId in video.categorias) {
              final catName = categoryMap[catId] ?? 'Desconocida';
              videosByCategory.putIfAbsent(catName, () => []);
              videosByCategory[catName]!.add(video);
            }
          }

          if (videosByCategory.isEmpty) {
            videosByCategory['Todos'] = videos;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: videosByCategory.entries.map((entry) {
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

                  // Thumbnails horizontales
                  SizedBox(
                    height: 200, // Altura de los posters
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final video = entry.value[index];

                        // ⚠ IMPORTANTE: ImageCard debe usar URL completa
                        // http://10.0.2.2:3000/static/${video.thumbnail}/thumbnail.jpg
                        return ImageCard(
                          video: video,
                          db: db,
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
