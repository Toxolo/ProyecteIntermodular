class Video {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String thumbnail;
  final List<int> categorias;
  final int chapter;
  final int season;
  final int series;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnail,
    required this.categorias,
    required this.chapter,
    required this.season,
    required this.series,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,

      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',

      categorias: json['category'] != null
          ? List<int>.from(
              json['category'].map((e) => e['id'] as int),
            )
          : [],

      chapter: json['chapter'] ?? 0,
      season: json['season'] ?? 0,
      
      series: json['series'] != null
          ? json['series']['id'] as int
          : 0,
    );
  }
}
