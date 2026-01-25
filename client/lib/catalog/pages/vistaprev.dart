import 'package:client/catalog/widgets/VideoPlayerHLS.dart' show VideoPlayerHLS;
import 'package:client/catalog/widgets/menu_de_llistes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/local/app_database.dart';
import '../../services/video_list_service.dart';
import '../catalog_styles.dart';
import '../../models/video_mapper.dart';
import '../../services/video_service.dart';
import '../widgets/series_episodes_section.dart';

class VistaPrev extends StatelessWidget {
  final int videoId;
  final AppDatabase db;

  const VistaPrev({
    super.key,
    required this.videoId,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    final videoListService = VideoListService(db.listsDao);

    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      body: Stack(
        children: [
          FutureBuilder<Video>(
            future: VideoService.getVideoById(videoId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text(
                    'No se pudo cargar el video',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final video = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🖼 Thumbnail
                    Image.network(
                      'http://10.0.2.2:3000/static/${video.thumbnail}/thumbnail.jpg',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerHLS(
                              url:
                                  'http://10.0.2.2:3000/static/${video.thumbnail}/index.m3u8',
                              onBack: () {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                ]);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('REPRODUCIR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddToListBottomSheet(
                                service: videoListService,
                                videoId: video.id,
                              ),
                            );
                          },
                          child: Column(
                            children: const [
                              Icon(Icons.menu, color: Colors.yellow, size: 30),
                              SizedBox(height: 4),
                              Text(
                                'Añadir a lista',
                                style: TextStyle(color: Colors.yellow, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: const [
                            Text('*****',
                                style: TextStyle(color: Colors.yellow, fontSize: 22)),
                            SizedBox(height: 4),
                            Text('Valoración',
                                style: TextStyle(color: Colors.yellow, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        video.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // ── Llista de la sèrie
                    SeriesEpisodesSection(
                      seriesId: video.series,
                      serieName: 'Episodis',
                      db: db,
                      currentVideoId: video.id, // no repetir el vídeo actual
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),

          // ⬅ Tornar enrere
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
