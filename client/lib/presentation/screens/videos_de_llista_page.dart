import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/data_sources/ApiService.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/presentation/screens/VistaPrevScreen.dart';
import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import '../catalog_styles.dart';

class VideosDeLlistaPage extends StatefulWidget {
  final AppDatabase db;
  final VideoList llista;

  const VideosDeLlistaPage({super.key, required this.db, required this.llista});

  @override
  State<VideosDeLlistaPage> createState() => _VideosDeLlistaPageState();
}

class _VideosDeLlistaPageState extends State<VideosDeLlistaPage> {
  late final ApiService _api;
  List<Video> _videos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = ApiService('http://10.0.2.2:8090');
    _loadVideosFromList();
  }

  Future<void> _loadVideosFromList() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get video IDs from the local database
      final items = await widget.db.listsDao.getVideosInList(widget.llista.id);
      if (items.isEmpty) {
        if (mounted) {
          setState(() {
            _videos = [];
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Fetch all video details in parallel
      final videoFutures = items
          .map((item) => _api.getVideoById(item.videoId))
          .toList();
      final results = await Future.wait(videoFutures);

      // 3. Filter out any potential nulls from failed calls and ensure type correctness
      final videos = results.map((item) => VideoMapper.fromJson(item)).toList();

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

    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return InkWell(
          onTap: () {
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
                  SizedBox(
                    width: 120,
                    height: 70,
                    child: Image.network(
                      'http://10.0.2.2:3000/static/${video.id}/thumbnail.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white12,
                        child: const Icon(Icons.videocam, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
