import 'package:client/catalog/widgets/VideoPlayerHLS.dart' show VideoPlayerHLS;
import 'package:client/catalog/widgets/menu_de_llistes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/local/app_database.dart';
import '../../services/video_list_service.dart';
import '../catalog_styles.dart';
import '../../models/video_mapper.dart';
import '../../services/video_service.dart';

class VistaPrev extends StatelessWidget {
  final int videoId;
  final AppDatabase db; // necessitem la BD per crear el servei

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
          Column(
            children: [
              // Banner / Imatge
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.cyan,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder<Video>(
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            video.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ▶ Botó reproduir
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerHLS(
                                    url: 'http://10.0.2.2:3000/static/1768551796479/index.m3u8', // url
                                    onBack: () {
                                      // Tornem a portrait
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
                              // Afegir a llista
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

                              // Valoració
                              Column(
                                children: const [
                                  Text(
                                    '*****',
                                    style: TextStyle(color: Colors.yellow, fontSize: 22),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Valoración',
                                    style: TextStyle(color: Colors.yellow, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Text(
                            video.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // 🔙 Fletxa de tornar a catàleg
          Positioned(
            top: 40,
            right: 15,
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
