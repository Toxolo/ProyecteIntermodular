import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/VistaPrevScreen.dart';

// Sección que muestra la lista de episodios de una serie concreta
class SeriesEpisodesSection extends StatefulWidget {
  final int seriesId; // ID de la serie cuyos episodios queremos mostrar
  final String serieName; // Nombre de la serie (para el título)
  final AppDatabase db; // Base de datos local (se pasa a VistaPrev)
  final int? currentVideoId; // Opcional: ID del vídeo que se está viendo ahora

  const SeriesEpisodesSection({
    super.key,
    required this.seriesId,
    required this.serieName,
    required this.db,
    this.currentVideoId,
  });

  @override
  State<SeriesEpisodesSection> createState() => _SeriesEpisodesSectionState();
}

class _SeriesEpisodesSectionState extends State<SeriesEpisodesSection> {
  // Instancia singleton del servicio API
  late final ApiService _api;

  // Lista de episodios (vídeos) de la serie
  List<Video> _episodes = [];

  // Estado de carga inicial
  bool _isLoading = true;

  // Mensaje de error si falla la carga
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = ApiService.instance;
    _loadEpisodes();
  }

  // Carga todos los episodios de la serie (ordenados por temporada y capítulo)
  Future<void> _loadEpisodes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Llamada al API que devuelve episodios ordenados
      final videosJson = await _api.getVideosBySeries(widget.seriesId);

      // Convertimos JSON → objetos Video
      final episodes = videosJson.map((json) {
        return VideoMapper.fromJson(json);
      }).toList();

      if (mounted) {
        setState(() {
          _episodes = episodes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al carregar els episodis: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras carga → spinner centrado
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Error → mensaje + botón reintentar
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 36),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEpisodes,
                child: const Text('Tornar a intentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Sin episodios → mensaje informativo
    if (_episodes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No hi ha episodis disponibles',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Lista vertical de episodios
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // Título de la sección
          Text(
            '${widget.serieName} · Episodis',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Generamos una tarjeta por cada episodio
          ..._episodes.map((episode) => _buildEpisodeCard(episode)),
        ],
      ),
    );
  }

  // Tarjeta de cada episodio: miniatura + título + temporada/capítulo + duración
  // Resalta visualmente si es el episodio actual
  Widget _buildEpisodeCard(Video episode) {
    // Comprobamos si este es el vídeo que se está viendo ahora
    final isCurrent =
        widget.currentVideoId != null && episode.id == widget.currentVideoId;

    return InkWell(
      // Al tocar → navega a VistaPrev (pero NO si ya estamos en ese vídeo)
      onTap: () {
        if (!isCurrent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VistaPrev(videoId: episode.id, db: widget.db),
            ),
          );
        }
      },
      child: Card(
        // Color diferente si es el episodio actual
        color: isCurrent ? Colors.yellow[900] : Colors.grey[900],
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Miniatura del episodio
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 110,
                  height: 65,
                  child: CachedNetworkImage(
                    imageUrl: '$expressUrl/static/${episode.id}/thumbnail.jpg',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.white38),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Información del episodio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.titol,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Temporada ${episode.temporada} · Capítol ${episode.capitol}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white70 : Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    if (episode.duracio > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${episode.duracio} min',
                        style: TextStyle(
                          color: isCurrent ? Colors.white60 : Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Icono: play grande si es actual, play pequeño si no
              if (isCurrent)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.yellow,
                    size: 32,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white54,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
