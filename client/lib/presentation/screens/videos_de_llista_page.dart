import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/presentation/screens/VistaPrevScreen.dart';
import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import '../catalog_styles.dart';

// Pantalla que muestra todos los vídeos guardados en una lista concreta del usuario
class VideosDeLlistaPage extends StatefulWidget {
  final AppDatabase db;
  final VideoList llista;

  const VideosDeLlistaPage({super.key, required this.db, required this.llista});

  @override
  State<VideosDeLlistaPage> createState() => _VideosDeLlistaPageState();
}

class _VideosDeLlistaPageState extends State<VideosDeLlistaPage> {
  // Instancia singleton del servicio API (Dio con token automático)
  final api = ApiService.instance;

  // Lista de vídeos cargados desde la API (solo los que están en la lista)
  List<Video> _videos = [];

  // Controla el estado de carga inicial
  bool _isLoading = true;

  // Mensaje de error si falla alguna petición
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Cargamos los vídeos de la lista al abrir la pantalla
    _loadVideosFromList();
  }

  // Carga los vídeos de la lista local y luego sus detalles desde la API
  Future<void> _loadVideosFromList() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Obtenemos solo los IDs de vídeos que están en esta lista (base de datos local)
      final items = await widget.db.listsDao.getVideosInList(widget.llista.id);

      // Si no hay vídeos → terminamos rápido
      if (items.isEmpty) {
        if (mounted) {
          setState(() {
            _videos = [];
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Creamos una lista de Futures para obtener detalles de cada vídeo en paralelo
      final videoFutures = items
          .map((item) => api.getVideoById(item.videoId))
          .toList();

      // Esperamos a que todas las peticiones terminen
      final results = await Future.wait(videoFutures);

      // 3. Convertimos los JSON válidos a objetos Video (filtramos nulls implícitamente)
      final videos = results
          .where(
            (item) => item != null,
          ) // evitamos nulls si alguna petición falló
          .map((item) => VideoMapper.fromJson(item!))
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
          _errorMessage =
              'Error al carregar els vídeos de la llista: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.llista.name),
      ),
      body: _buildBody(),
    );
  }

  // Decide qué mostrar según el estado: cargando, error, vacío o lista de vídeos
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
              onPressed: _loadVideosFromList,
              child: const Text('Tornar a intentar'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text(
          'No hi ha vídeos en aquesta llista.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    // Lista scrollable de vídeos de la lista seleccionada
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return InkWell(
          onTap: () {
            // Navega a la pantalla de vista previa del vídeo
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VistaPrev(videoId: video.id, db: widget.db),
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
                  // Miniatura del vídeo
                  SizedBox(
                    width: 120,
                    height: 70,
                    child: Image.network(
                      '$expressUrl/static/${video.id}/thumbnail.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white12,
                        child: const Icon(Icons.videocam, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Información del vídeo
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Temporada ${video.temporada}, Capítol ${video.capitol}',
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
  }
}
