import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'VistaPrevScreen.dart';

// Pantalla que muestra todos los episodios (vídeos) de una serie concreta
class VideosDeSeriePage extends StatefulWidget {
  final AppDatabase db;
  final int seriesId;

  const VideosDeSeriePage({
    super.key,
    required this.db,
    required this.seriesId,
  });

  @override
  State<VideosDeSeriePage> createState() => _VideosDeSeriePageState();
}

class _VideosDeSeriePageState extends State<VideosDeSeriePage> {
  // Instancia singleton del servicio API (Dio configurado con token)
  late final ApiService _api;

  // Lista de vídeos (episodios) de la serie
  List<Video> _videos = [];

  // Controla el estado de carga inicial
  bool _isLoading = true;

  // Mensaje de error si falla la petición
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Obtenemos la instancia única del ApiService
    _api = ApiService.instance;

    // Cargamos los vídeos de la serie al abrir la pantalla
    _loadVideos();
  }

  // Carga los episodios de la serie desde la API
  Future<void> _loadVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Llamamos al método específico que filtra por serie y ordena por temporada/capítulo
      final videosJson = await _api.getVideosBySeries(widget.seriesId);

      // Convertimos cada JSON a objeto Video usando el mapper
      final videos = videosJson
          .map((json) => VideoMapper.fromJson(json))
          .toList();

      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al carregar els vídeos: ${e.toString()}';
        });
      }
    }
  }

  // Navegación personalizada con animación suave (fade + slide up)
  void _navigateToVideo(int videoId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return VistaPrev(db: widget.db, videoId: videoId);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Combinación de fade + deslizamiento desde abajo
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sèrie ${widget.seriesId}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  // Decide qué mostrar según el estado: cargando, error, vacío o lista
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideos,
              child: const Text('Tornar a intentar'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text(
          'No hi ha vídeos per a aquesta sèrie.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // Lista scrollable de episodios
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildVideoCard(video);
      },
    );
  }

  // Tarjeta de cada episodio: thumbnail + título + temporada/capítulo
  Widget _buildVideoCard(Video video) {
    return InkWell(
      onTap: () => _navigateToVideo(video.id),
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Miniatura del vídeo
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 120,
                  height: 70,
                  child: Image.network(
                    '$expressUrl/static/${video.id}/thumbnail.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
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
                      video.titol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Temporada ${video.temporada} · Capítol ${video.capitol}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha indicadora
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
