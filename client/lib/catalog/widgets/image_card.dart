
import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../pages/vistaprev.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 160,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: CatalogStyles.cardGold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VistaPrev()),
          );
        },
        child: Icon(
          Icons.circle,
          size: 40, // Adjust size as needed
          color: Colors.white, // Change color if needed
        ),
      ),
        //aqui poner la imagen del video en vertical
      );
  }
}