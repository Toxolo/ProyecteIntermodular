class Video {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String thumbnail;
  final List<int> categorias;
  final int chapter;
  final int season;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnail,
    required this.categorias,
    required this.chapter,
    required this.season,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      categorias: json['category'] != null
          ? List<int>.from(json['category'].map((e) => e['id']))
          : [],
      chapter: json['chapter'] ?? 0,
      season: json['season'] ?? 0,
    );
  }
}
