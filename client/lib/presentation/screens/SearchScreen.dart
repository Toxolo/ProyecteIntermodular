import 'dart:async';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Serie.dart';
import 'package:client/infrastructure/data_sources/ApiService.dart';
import 'package:client/infrastructure/mappers/SerieMapper.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/series_episodes_section.dart';

class SearchPage extends StatefulWidget {
  final AppDatabase db;
  const SearchPage({super.key, required this.db});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Use singleton instance
  late final ApiService _api;

  String _searchQuery = '';
  List<Serie> _allSeries = [];
  List<Serie> _filteredResults = [];
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _debounceTimer;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _api = ApiService('$baseUrl:8090');
    _loadSeries();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSeries() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final seriesJson = await _api.getSeries();

      // Mappers now return domain entities directly
      final series = seriesJson.map((json) {
        return SerieMapper.fromJson(json);
      }).toList();

      if (mounted) {
        setState(() {
          _allSeries = series;
          _filteredResults = List.from(series);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al carregar les sèries: ${e.toString()}';
        });
      }
    }
  }

  void _onSearchChanged(String input) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      final trimmed = input.trim().toLowerCase();

      setState(() {
        _searchQuery = input;

        if (trimmed.isEmpty) {
          _filteredResults = List.from(_allSeries);
        } else {
          _filteredResults = _allSeries
              .where((serie) => serie.nom.toLowerCase().contains(trimmed))
              .toList();
        }
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Buscar sèries'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
              onPressed: _loadSeries,
              child: const Text('Tornar a intentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildResultsList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar sèrie...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildResultsList() {
    if (_filteredResults.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.white38, size: 64),
            SizedBox(height: 16),
            Text(
              "No s'han trobat sèries",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    if (_filteredResults.isEmpty) {
      return const Center(
        child: Text(
          'No hi ha sèries disponibles',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredResults.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        return _SerieTile(serie: _filteredResults[index], db: widget.db);
      },
    );
  }
}

class _SerieTile extends StatelessWidget {
  final Serie serie;
  final AppDatabase db;

  const _SerieTile({required this.serie, required this.db});

  static const _fallbackImageUrl =
      'https://ih1.redbubble.net/image.1861329650.2941/flat,750x,075,f-pad,750x1000,f8f8f8.jpg';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToSerieDetail(context),
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: _buildThumbnail(),
          title: Text(
            serie.nom,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        height: 60,
        child: CachedNetworkImage(
          imageUrl: '$baseUrl:3000/static/${serie.id}/thumbnail.jpg',
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
          errorWidget: (context, url, error) => Image.network(
            _fallbackImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.movie, color: Colors.white38),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSerieDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(serie.nom),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: SeriesEpisodesSection(
            seriesId: serie.id,
            serieName: serie.nom,
            db: db,
          ),
        ),
      ),
    );
  }
}
