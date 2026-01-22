import 'package:client/data/local/app_database.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'image_card.dart';
import '../../models/video_mapper.dart';
import '../../services/video_service.dart';

class LlistesSection extends StatelessWidget {
  final AppDatabase db; // <-- BD passada des de main o page

  const LlistesSection({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoList>>(
      future: db.listsDao.getAllLists(), // obtenim les llistes reals
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No tens cap llista',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final lists = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lists.map((list) {
            return Column(
              children: [
                _SingleCategory(db: db, list: list),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _SingleCategory extends StatelessWidget {
  final AppDatabase db;
  final VideoList list;

  const _SingleCategory({required this.db, required this.list});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            list.name,
            style: CatalogStyles.sectionTitle,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: FutureBuilder<List<VideoListItem>>(
            future: db.listsDao.getVideosInList(list.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox();
              }

              final items = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final videoId = items[index].videoId;
                  // Obtenim la info completa del vídeo
                  return FutureBuilder<Video>(
                    future: VideoService.getVideoById(videoId),
                    builder: (context, videoSnap) {
                      if (!videoSnap.hasData) return const SizedBox();
                      return ImageCard(
                        video: videoSnap.data!,
                        db: db, // <-- si vols afegir més vídeos a llista
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
