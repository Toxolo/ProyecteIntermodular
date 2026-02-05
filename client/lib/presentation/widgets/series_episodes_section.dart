import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/VistaPrevScreen.dart';

class SeriesEpisodesSection extends StatefulWidget {
  final int seriesId;
  final String serieName;
  final AppDatabase db;
  final int? currentVideoId;

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
  late final ApiService _api;
  List<Video> _episodes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = ApiService(baseUrl);
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videosJson = await _api.getVideosBySeries(widget.seriesId);

      // Mapper now returns Video domain entities directly
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            '${widget.serieName} · Episodis',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._episodes.map((episode) => _buildEpisodeCard(episode)),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(Video episode) {
    final isCurrent =
        widget.currentVideoId != null && episode.id == widget.currentVideoId;

    return InkWell(
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
        color: isCurrent ? Colors.yellow[900] : Colors.grey[900],
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 110,
                  height: 65,
                  child: CachedNetworkImage(
                    imageUrl:
                        '$baseUrl:3000/static/${episode.id}/thumbnail.jpg',
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

              // Episode info
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

              // Current indicator or play icon
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
