import 'package:flutter/material.dart';
import 'package:client/data/local/app_database.dart';
import '../../models/video_mapper.dart';
import 'vistaprev.dart';

class VideosDeSeriePage extends StatelessWidget {
  final AppDatabase db;
  final int series;
  final List<Video> videos;

  const VideosDeSeriePage({
    super.key,
    required this.db,
    required this.series,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sèrie $series'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VistaPrev(
                    db: db,
                    videoId: video.id,
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 70,
                      child: video.thumbnail.isNotEmpty
                          ? Image.network(
                              'http://10.0.2.2:3000/static/${video.thumbnail}/thumbnail.jpg',
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.white12,
                              child: const Icon(Icons.videocam, color: Colors.white),
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
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Temporada ${video.season}, Capítol ${video.chapter}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
