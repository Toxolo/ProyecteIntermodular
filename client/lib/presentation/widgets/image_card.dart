import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/VistaPrevScreen.dart';
import '../../infrastructure/data_sources/local/app_database.dart';

// Widget reutilizable que muestra una tarjeta con la miniatura de un vídeo
class ImageCard extends StatelessWidget {
  // El vídeo que se va a mostrar en la tarjeta
  final Video video;

  // Base de datos local (se pasa a la pantalla de detalle)
  final AppDatabase db;

  const ImageCard({super.key, required this.video, required this.db});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Al tocar la tarjeta → navega a la vista previa del vídeo
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VistaPrev(videoId: video.id, db: db),
          ),
        );
      },

      child: Container(
        // Tamaño fijo pensado para listas horizontales
        width: 240,
        height: 100,

        // Separación entre tarjetas en la lista horizontal
        margin: const EdgeInsets.only(right: 10),

        // Fondo oscuro y bordes redondeados
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade900,
        ),

        child: Stack(
          // Hace que los hijos ocupen todo el espacio del contenedor
          fit: StackFit.expand,
          children: [
            // Imagen de fondo (thumbnail del vídeo)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                // URL del thumbnail desde el servidor
                imageUrl: '$expressUrl/static/${video.id}/thumbnail.jpg',
                fit: BoxFit.cover,

                // Mientras carga la imagen → muestra un spinner
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  ),
                ),

                // Si falla la carga → muestra un icono de película
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.movie, color: Colors.white38),
                ),
              ),
            ),

            // Barra inferior semitransparente con el título del vídeo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  video.titol,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  // Limita a 2 líneas y pone puntos suspensivos si es muy largo
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
