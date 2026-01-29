class Serie {
  final int id;
  final String nom;

  Serie({required this.id, required this.nom});

  @override
  String toString() {
    return 'Serie(id: $id, nom: $nom)';
  }
}
