import 'package:flutter/material.dart';
import '../../models/video.dart';
import '../../services/video_service.dart';
import 'image_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: FutureBuilder<List<Video>>(
            future: VideoService.getVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay vídeos',
                    style: TextStyle(color: Color.fromARGB(255, 190, 159, 0)),
                  ),
                );
              }

              final videos = snapshot.data!; // lista consegida correctamente

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length, // cantidad dinámica de cards
                itemBuilder: (context, index) {
                  return ImageCard(video: videos[index]);  // card con datos del video
                },
              );
            },
          ),
        ),
      ],
      ),
    );
  }
}
