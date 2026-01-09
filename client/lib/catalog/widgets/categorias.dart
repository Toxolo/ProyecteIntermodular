import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'image_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column( //le ponemos a mano el nombre de las categorias
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SingleCategory(title: 'Tendencias'),
        SizedBox(height: 20),
        _SingleCategory(title: 'Recomendados'),
        SizedBox(height: 20),
        _SingleCategory(title: 'Series'),
      ],
    );
  }
}

class _SingleCategory extends StatelessWidget {
  final String title;

  const _SingleCategory({ //Creamos el constructor del widget y obligamos a pasar el nombre de la categoria.
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, //Alinea los elementos hijos al inicio horizontal del contenedor.
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: CatalogStyles.sectionTitle,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              ImageCard(),
              ImageCard(),
              ImageCard(),
              ImageCard(),
            ],
          ),
        ),
      ],
    );
  }
}
