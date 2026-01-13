import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'image_card.dart';
import '../../models/video.dart';
import '../../services/video_service.dart';

class llistesSection extends StatelessWidget {
  const llistesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // alineacion de las listas
      children: const [
        _SingleCategory(title: 'lista 1'), // listas creadas a mano de usuario
        SizedBox(height: 20), // separación visual entre listas
        _SingleCategory(title: 'lista 2'),
        SizedBox(height: 20),
        _SingleCategory(title: 'lista 3'),
      ],
    );
  }
}

class _SingleCategory extends StatelessWidget {
  final String title;

  const _SingleCategory({
    required this.title, // título de lista lo ponemos como obligatorio
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: CatalogStyles.sectionTitle,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: FutureBuilder<List<Video>>(
            future: VideoService.getVideos(), // obtenemos vídeos del backend
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(), // el tipico coso de carga
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(); // evita errores sin datos
              }

              final videos = snapshot.data!; // lista obtenida correctamente

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: videos.length, // cantidad dinámica de cards
                itemBuilder: (context, index) {
                  return ImageCard(video: videos[index]); // card con datos del video
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
