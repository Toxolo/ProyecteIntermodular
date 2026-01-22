import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import '../../models/video_mapper.dart';
import '../pages/vistaprev.dart';
import '../../data/local/app_database.dart'; 

class ImageCard extends StatelessWidget {
  final Video video;
  final AppDatabase db; 

  const ImageCard({super.key, required this.video, required this.db});

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
              builder: (context) => VistaPrev(
                videoId: video.id,
                db: db, // <-- passem la BD
              ),
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
