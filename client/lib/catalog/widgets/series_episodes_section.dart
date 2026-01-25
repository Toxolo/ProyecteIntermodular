import 'package:client/services/Serie_service.dart';
import 'package:flutter/material.dart';
import '../../models/video_mapper.dart';
import '../pages/vistaprev.dart';
import '../../data/local/app_database.dart';

class SeriesEpisodesSection extends StatelessWidget {
  final int seriesId;
  final String serieName;
  final AppDatabase db;

  const SeriesEpisodesSection({
    super.key,
    required this.seriesId,
    required this.serieName,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Video>>(
      future: SerieService.getVideosBySeries(seriesId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final videos = snapshot.data!;
        if (videos.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // 🏷 Nom de la sèrie
            Text(
              serieName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...videos.map((video) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VistaPrev(
                        videoId: video.id,
                        db: db,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 65,
                          child: Image.network(
                            'http://10.0.2.2:3000/static/${video.thumbnail}/thumbnail.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Temporada ${video.season} · Capítol ${video.chapter}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
