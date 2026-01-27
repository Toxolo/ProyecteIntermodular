import 'package:client/catalog/widgets/series_episodes_section.dart';
import 'package:flutter/material.dart';
import 'package:client/services/Serie_service.dart';
import '../../models/serie_mapper.dart';
import '../../data/local/app_database.dart';

class SearchPage extends StatefulWidget {
  final AppDatabase db;

  const SearchPage({super.key, required this.db});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  List<Serie> allSeries = [];
  List<Serie> results = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSeries();
  }

  Future<void> loadSeries() async {
    try {
      allSeries = await SerieService.getCategories();
      results = allSeries;
    } catch (e) {
      allSeries = [];
      results = [];
      // opcional: mostrar error
    }
    setState(() {
      loading = false;
    });
  }

  void search(String input) {
    setState(() {
      query = input;
      results = allSeries
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar sèries'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escriu el nom de la sèrie...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: search,
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                          child: Text(
                            'No s’han trobat sèries',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final serie = results[index];
                            return FutureBuilder(
                              future: SerieService.getVideosBySeries(serie.id),
                              builder: (context, snapshot) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(serie.name),
                                            backgroundColor: Colors.black,
                                          ),
                                          body: SeriesEpisodesSection(
                                            seriesId: serie.id,
                                            serieName: serie.name,
                                            db: widget.db,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.grey[900],
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            height: 60,
                                            child: snapshot.hasData &&
                                                    snapshot.data!.isNotEmpty
                                                ? Image.network(
                                                    'http://10.0.2.2:3000/static/${snapshot.data![0].thumbnail}/thumbnail.jpg',
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (context, error, stackTrace) {
                                                      return Image.network(
                                                        'https://ih1.redbubble.net/image.1861329650.2941/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.network(
                                                    'https://ih1.redbubble.net/image.1861329650.2941/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              serie.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
