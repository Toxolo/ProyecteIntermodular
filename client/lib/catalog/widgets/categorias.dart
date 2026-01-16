import 'package:flutter/material.dart';

import 'package:client/models/video_mapper.dart';
import 'package:client/models/category.dart';
import 'package:client/services/video_service.dart';
import 'package:client/services/category_service.dart';

import 'image_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

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
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No hay datos',
                style: TextStyle(color: Color.fromARGB(255, 190, 159, 0)),
              ),
            );
          }

          final videos = snapshot.data![0] as List<Video>;
          final categories = snapshot.data![1] as List<Category>;

          // Convertimos List<Category> → Map<int, String>
          final Map<int, String> categoryMap = {
            for (final c in categories) c.id: c.name,
          };

          // Agrupamos vídeos por categoría
          final Map<String, List<Video>> videosByCategory = {};

          for (final video in videos) {
            for (final catId in video.categorias) {
              final catName = categoryMap[catId] ?? 'Desconocida';
              videosByCategory.putIfAbsent(catName, () => []);
              videosByCategory[catName]!.add(video);
            }
          }

          // fallback si no hay categorías
          if (videosByCategory.isEmpty) {
            videosByCategory['Todos'] = videos;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: videosByCategory.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        return ImageCard(video: entry.value[index]);
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
