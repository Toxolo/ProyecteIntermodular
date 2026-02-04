class Categoria {
  final int id;
  final String nom;

  Categoria({required this.id, required this.nom});

  @override
  String toString() {
    return 'Categoria(id: $id, nom: $nom)';
  }
}
