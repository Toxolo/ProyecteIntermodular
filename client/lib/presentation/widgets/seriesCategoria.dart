import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Categoria.dart';
import 'package:client/domain/entities/Serie.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/presentation/screens/VistaPrevScreen.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/CategoriaMapper.dart';
import 'package:client/infrastructure/mappers/SerieMapper.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:flutter/material.dart';

class CategorySection extends StatefulWidget {
  final AppDatabase db;

  const CategorySection({super.key, required this.db});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  late final ApiService _api;

  @override
  void initState() {
    super.initState();
    _api = ApiService(baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<(List<Video>, List<Serie>, List<Categoria>)>(
        future: _loadAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error al carregar: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No hi ha dades',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final (videos, series, categories) = snapshot.data!;

          return _buildCategoryContent(videos, series, categories);
        },
      ),
    );
  }

  Future<(List<Video>, List<Serie>, List<Categoria>)> _loadAllData() async {
    final results = await Future.wait([
      _api.getVideos(),
      _api.getSeries(),
      _api.getCategories(),
    ]);

    // Mappers now return domain entities directly
    final videos = (results[0])
        .map((json) => VideoMapper.fromJson(json))
        .toList();
    final series = (results[1])
        .map((json) => SerieMapper.fromJson(json))
        .toList();
    final categories = (results[2])
        .map((json) => CategoriaMapper.fromJson(json))
        .toList();

    return (videos, series, categories);
  }

  Widget _buildCategoryContent(
    List<Video> videos,
    List<Serie> series,
    List<Categoria> categories,
  ) {
    // Map id → nombre categoría
    final categoryMap = <int, String>{for (final c in categories) c.id: c.nom};

    // Map serieId → primer vídeo
    final serieToFirstVideo = <int, Video>{};
    for (final video in videos) {
      if (!serieToFirstVideo.containsKey(video.serie)) {
        serieToFirstVideo[video.serie] = video;
      }
    }

    // Agrupar series por categorías
    final seriesByCategory = <String, List<Map<String, dynamic>>>{};

    for (final serie in series) {
      final serieVideos = videos.where((v) => v.serie == serie.id).toList();
      if (serieVideos.isEmpty) continue;

      final firstVideo = serieToFirstVideo[serie.id];
      if (firstVideo == null) continue;

      final serieCategories = <String>{};
      for (final v in serieVideos) {
        for (final catId in v.categories) {
          final catName = categoryMap[catId] ?? 'Desconeguda';
          serieCategories.add(catName);
        }
      }

      for (final catName in serieCategories) {
        seriesByCategory.putIfAbsent(catName, () => []);
        seriesByCategory[catName]!.add({
          'serie': serie,
          'firstVideo': firstVideo,
        });
      }
    }

    // Caso borde: sin categorías → "Totes"
    if (seriesByCategory.isEmpty && videos.isNotEmpty) {
      seriesByCategory['Totes'] = series
          .where((s) => serieToFirstVideo.containsKey(s.id))
          .map((s) {
            final firstVideo = serieToFirstVideo[s.id]!;
            return {'serie': s, 'firstVideo': firstVideo};
          })
          .toList();
    }

    if (seriesByCategory.isEmpty) {
      return const Center(
        child: Text(
          'No hi ha sèries disponibles',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seriesByCategory.entries.map((entry) {
        return _buildCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(
    String categoryName,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final serie = item['serie'] as Serie;
              final firstVideo = item['firstVideo'] as Video;

              return _buildSerieCard(serie, firstVideo);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSerieCard(Serie serie, Video firstVideo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VistaPrev(videoId: firstVideo.id, db: widget.db),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl:
                      '$baseUrl:3000/static/${firstVideo.id}/thumbnail.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.movie,
                      color: Colors.white38,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              serie.nom,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
