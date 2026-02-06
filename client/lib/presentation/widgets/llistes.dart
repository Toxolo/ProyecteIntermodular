import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'image_card.dart';

class LlistesSection extends StatelessWidget {
  final AppDatabase db;

  const LlistesSection({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoList>>(
      future: db.listsDao.getAllLists(),
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
    // Use singleton instance
    final api = ApiService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(list.name, style: CatalogStyles.sectionTitle),
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
                return const Center(
                  child: Text(
                    'Llista buida',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              final items = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final videoId = items[index].videoId;

                  return FutureBuilder<dynamic>(
                    future: api.getVideoById(videoId),
                    builder: (context, videoSnap) {
                      if (videoSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 240,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      if (!videoSnap.hasData) {
                        return const SizedBox.shrink();
                      }

                      // Mapper now returns Video domain entity directly
                      final video = VideoMapper.fromJson(videoSnap.data);

                      return ImageCard(video: video, db: db);
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
