import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Categoria.dart';
import 'package:client/domain/entities/Serie.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:client/presentation/screens/VistaPrevScreen.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/CategoriaMapper.dart';
import 'package:client/infrastructure/mappers/SerieMapper.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sección principal de categorías en el catálogo
class CategorySection extends ConsumerStatefulWidget {
  final AppDatabase db;

  const CategorySection({super.key, required this.db});

  @override
  ConsumerState<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<CategorySection> {
  // Instancia del servicio API obtenida del provider de Riverpod
  late final ApiService _api;

  @override
  void initState() {
    super.initState();
    // Leemos el provider para obtener ApiService ya inicializado
    _api = ref.read(apiServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<(List<Video>, List<Serie>, List<Categoria>)>(
        // Carga en paralelo: vídeos, series y categorías
        future: _loadAllData(),
        builder: (context, snapshot) {
          // Mientras carga → spinner centrado
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Error → mensaje con icono
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

          // Sin datos → mensaje simple
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

  // Carga simultánea de los tres conjuntos de datos principales
  Future<(List<Video>, List<Serie>, List<Categoria>)> _loadAllData() async {
    // Ejecutamos las 3 peticiones en paralelo
    final results = await Future.wait([
      _api.getVideos(),
      _api.getSeries(),
      _api.getCategories(),
    ]);

    // Convertimos cada lista JSON → entidades de dominio
    final videos = (results[0] as List<dynamic>)
        .map((json) => VideoMapper.fromJson(json))
        .toList();

    final series = (results[1] as List<dynamic>)
        .map((json) => SerieMapper.fromJson(json))
        .toList();

    final categories = (results[2] as List<dynamic>)
        .map((json) => CategoriaMapper.fromJson(json))
        .toList();

    return (videos, series, categories);
  }

  // Construye el contenido final: categorías con sus series
  Widget _buildCategoryContent(
    List<Video> videos,
    List<Serie> series,
    List<Categoria> categories,
  ) {
    // Mapa rápido: id categoría → nombre
    final categoryMap = <int, String>{for (final c in categories) c.id: c.nom};

    // Mapa: serieId → primer vídeo encontrado (para mostrar miniatura)
    final serieToFirstVideo = <int, Video>{};
    for (final video in videos) {
      if (!serieToFirstVideo.containsKey(video.serie)) {
        serieToFirstVideo[video.serie] = video;
      }
    }

    // Agrupamos series por categoría (una serie puede estar en varias)
    final seriesByCategory = <String, List<Map<String, dynamic>>>{};

    for (final serie in series) {
      // Vídeos de esta serie
      final serieVideos = videos.where((v) => v.serie == serie.id).toList();
      if (serieVideos.isEmpty) continue;

      final firstVideo = serieToFirstVideo[serie.id];
      if (firstVideo == null) continue;

      // Conjunto de nombres de categorías de esta serie
      final serieCategories = <String>{};
      for (final v in serieVideos) {
        for (final catId in v.categories) {
          final catName = categoryMap[catId] ?? 'Desconeguda';
          serieCategories.add(catName);
        }
      }

      // Añadimos la serie a cada categoría que le corresponde
      for (final catName in serieCategories) {
        seriesByCategory.putIfAbsent(catName, () => []);
        seriesByCategory[catName]!.add({
          'serie': serie,
          'firstVideo': firstVideo,
        });
      }
    }

    // Caso borde: si no hay categorías asignadas pero sí series → grupo "Totes"
    if (seriesByCategory.isEmpty && videos.isNotEmpty) {
      seriesByCategory['Totes'] = series
          .where((s) => serieToFirstVideo.containsKey(s.id))
          .map((s) {
            final firstVideo = serieToFirstVideo[s.id]!;
            return {'serie': s, 'firstVideo': firstVideo};
          })
          .toList();
    }

    // Si después de todo no hay nada → mensaje
    if (seriesByCategory.isEmpty) {
      return const Center(
        child: Text(
          'No hi ha sèries disponibles',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Generamos una sección por cada categoría
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seriesByCategory.entries.map((entry) {
        return _buildCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  // Una sección individual: título de categoría + carrusel horizontal
  Widget _buildCategorySection(
    String categoryName,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Nombre de la categoría
        Text(
          categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Carrusel horizontal de series de esta categoría
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

  // Tarjeta de cada serie: miniatura del primer vídeo + nombre de la serie
  Widget _buildSerieCard(Serie serie, Video firstVideo) {
    return GestureDetector(
      // Al tocar → abre la vista previa del primer vídeo de la serie
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
            // Miniatura ocupa la mayor parte de la tarjeta
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: '$expressUrl/static/${firstVideo.id}/thumbnail.jpg',
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

            // Nombre de la serie debajo
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
