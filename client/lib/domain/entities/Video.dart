class Video {
  final int id;
  final String titol;
  final String descripcio;
  final int temporada;
  final int capitol;
  final int serie;
  final int duracio;
  final List<int> categories;
  final double puntuacio;

  Video({
    required this.id,
    required this.titol,
    required this.descripcio,
    required this.serie,
    required this.temporada,
    required this.capitol,
    required this.duracio,
    required this.categories,
    required this.puntuacio,
  });

  @override
  String toString() {
    return 'Video(id: $id, titol: $titol, descripcio: $descripcio, serie: $serie, temporada: $temporada, capitol: $capitol, duracio: $duracio, categories: $categories, rating: $puntuacio)';
  }
}
