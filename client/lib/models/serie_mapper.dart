class Serie {
  final int id;
  final String name;

  Serie({
    required this.id,
    required this.name,
  });


  factory Serie.fromJson(Map<String, dynamic> json) {
    return Serie(
      id: json['id'] as int,
      name: json['name'] ?? 'Sèrie sense nom',
    );
  }
}
