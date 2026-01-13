import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../../models/video.dart';
import '../pages/vistaprev.dart';

class ImageCard extends StatelessWidget {
  final Video video;

  const ImageCard({super.key, required this.video});

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
            MaterialPageRoute(
              builder: (context) => VistaPrev(videoId: video.id),
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              video.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
