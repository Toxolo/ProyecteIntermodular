import 'package:flutter/material.dart';
import '../../models/video_mapper.dart';
import '../../services/video_service.dart';
import 'image_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder(
        // Carga vídeos y categorías
        future: VideoService.getVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No hay vídeos',
                style: TextStyle(color: Color.fromARGB(255, 190, 159, 0)),
              ),
            );
          }

          final videos = snapshot.data! as List<Video>; // lista de videos

          // pone videos por categoría
          final categoryMap = {
            1: "Acció",
            2: "Aventura",
            3: "Comedia",
            4: "Drama",
            5: "Ciència Ficció",
            6: "Animació",
          };

          final Map<String, List<Video>> videosByCategory = {};

          for (final video in videos) {
            for (final catId in video.categorias) {
              final catName = categoryMap[catId] ?? 'Desconocida';
              videosByCategory.putIfAbsent(catName, () => []);
              videosByCategory[catName]!.add(video);
            }
          }

          //si las categorias no van se muestran todos los videos
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
                  Text( //texto de titulo de categoria
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
                      itemCount: entry.value.length, // cantidad de videos por categoría
                      itemBuilder: (context, index) {
                        return ImageCard(
                          video: entry.value[index], // ponemos el card del video
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
