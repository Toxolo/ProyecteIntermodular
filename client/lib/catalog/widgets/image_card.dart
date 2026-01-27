import 'package:flutter/material.dart';
import '../../models/video_mapper.dart';
import '../pages/vistaprev.dart';
import '../../data/local/app_database.dart'; 

class ImageCard extends StatelessWidget {
  final Video video;
  final AppDatabase db; 

  const ImageCard({super.key, required this.video, required this.db});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VistaPrev(
              videoId: video.id,
              db: db,
            ),
          ),
        );
      },
      child: Container(
        width: 240,
        height: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade900, // color fallback
          image: DecorationImage(
            image: NetworkImage(
              'http://10.0.2.2:3000/static/${video.thumbnail}/thumbnail.jpg',
            ),
            fit: BoxFit.fill, // <-- Aquí fem que s’adapte completament
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.black54, // fons semi-transparent per llegibilitat
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Text(
            video.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
