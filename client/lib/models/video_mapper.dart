class Video {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String thumbnail;
  final List<int> categorias;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnail,
    required this.categorias,
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
    );
  }
}
