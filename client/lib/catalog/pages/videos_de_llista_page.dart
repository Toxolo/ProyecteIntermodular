import 'package:client/catalog/pages/vistaprev.dart';
import 'package:client/models/video_mapper.dart';
import 'package:flutter/material.dart';
import 'package:client/data/local/app_database.dart';
import '../catalog_styles.dart';
import '../../services/video_service.dart';

class VideosDeLlistaPage extends StatelessWidget {
  final AppDatabase db;
  final VideoList llista;

  const VideosDeLlistaPage({super.key, required this.db, required this.llista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(llista.name),
        
      ),
      body: FutureBuilder<List<VideoListItem>>(
        future: db.listsDao.getVideosInList(llista.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No hi ha vídeos a aquesta llista',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return FutureBuilder<Video>(
                future: VideoService.getVideoById(item.videoId),
                builder: (context, snapshotVideo) {
                  if (!snapshotVideo.hasData) {
                    return const SizedBox(
                        height: 80,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ));
                  }

                  final video = snapshotVideo.data!;

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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // ─── Imatge a l'esquerra ───
                           SizedBox(
                            width: 120,
                            height: 70,
                            child: video.thumbnail.isNotEmpty
                                ? Image.network(
                                    'http://10.0.2.2:3000/static/${video.thumbnail}/thumbnail.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Si la primera falla, carga esta segunda URL
                                      return Image.network(
                                        'https://ih1.redbubble.net/image.1861329650.2941/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Si también falla la segunda, mostramos un placeholder
                                          return Container(
                                            color: Colors.white12,
                                            child: const Icon(Icons.videocam, color: Colors.white),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.white12,
                                    child: const Icon(Icons.videocam, color: Colors.white),
                                  ),
                          ),

                            const SizedBox(width: 12),

                            // ─── Info a la dreta ───
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
              );
            },
          );
        },
      ),
    );
  }
}
