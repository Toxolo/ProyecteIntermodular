import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Serie.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:client/presentation/widgets/VideoPlayerHLS.dart';
import 'package:client/presentation/widgets/menu_de_llistes.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/infrastructure/mappers/SerieMapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/data_sources/local/app_database.dart';
import '../catalog_styles.dart';
import '../widgets/series_episodes_section.dart';

class VistaPrev extends ConsumerStatefulWidget {
  final int videoId;
  final AppDatabase db;

  const VistaPrev({super.key, required this.videoId, required this.db});

  @override
  ConsumerState<VistaPrev> createState() => _VistaPrevState();
}

class _VistaPrevState extends ConsumerState<VistaPrev> {
  late final ApiService _api;
  late final VideoListService _listService;
  Video? _video;
  Serie? _serie;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = ApiService.instance;
    _listService = VideoListService(widget.db.listsDao);
    _loadVideoDetails();
  }

  Future<void> _loadVideoDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videoJson = await _api.getVideoById(widget.videoId);
      final video = VideoMapper.fromJson(videoJson);

      Serie? serie;
      if (video.serie > 0) {
        final serieJson = await _api.getSerieById(video.serie);
        if (serieJson != null) {
          serie = SerieMapper.fromJson(serieJson);
        }
      }

      if (mounted) {
        setState(() {
          _video = video;
          _serie = serie;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al carregar els detalls: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            top: 40,
            left: 15,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    final user = ref.watch(userProvider);

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                onPressed: _loadVideoDetails,
                child: const Text('Tornar a intentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_video == null) {
      return const Center(
        child: Text(
          'No s\'ha pogut carregar el vídeo',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final video = _video!;
    final puntuacioInt = video.puntuacio.round();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          Image.network(
            '$expressUrl/static/${video.id}/thumbnail.jpg',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 220,
              color: Colors.grey[900],
              child: const Icon(Icons.movie, color: Colors.white38, size: 64),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              video.titol,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Play button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerHLS(
                    url: '$expressUrl/static/${video.id}/index.m3u8',
                    authToken: ref
                        .read(userProvider)
                        .getAccesToken(), // Pass it
                    onBack: () {
                      /* ... */
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
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Add to list
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddToListBottomSheet(
                      service: _listService,
                      videoId: video.id,
                    ),
                  );
                },
                child: Column(
                  children: const [
                    Icon(Icons.add, color: Colors.yellow, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Afegir a llista',
                      style: TextStyle(color: Colors.yellow, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Rating
              Column(
                children: [
                  Text(
                    '★' * puntuacioInt,
                    style: const TextStyle(color: Colors.yellow, fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Valoració',
                    style: TextStyle(color: Colors.yellow, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              video.descripcio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),

          // Series episodes
          if (_serie != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SeriesEpisodesSection(
                seriesId: video.serie,
                serieName: _serie!.nom,
                db: widget.db,
                currentVideoId: video.id,
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
