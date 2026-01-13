import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'catalog_page.dart';
import '../../models/video.dart'; // modelo del backend
import '../../services/video_service.dart'; // servicio API REST

class VistaPrev extends StatelessWidget {
  final int videoId; // id del video seleccionado

  const VistaPrev({super.key, required this.videoId}); // recibe id por parámetro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,

      body: Stack( // permite usar Positioned
        children: [
          Column(
            children: [

              Container(
                height: 220, // altura para la imagen
                width: double.infinity,
                color: Colors.cyan, // azul (quitar cuando pongamos ya la img)
                child: const Center(),// Más adelante aquí ira la Imagen
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder<Video>( // carga datos del video
                    future: VideoService.getVideoById(videoId), // llamada por id
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text(
                            'No se pudo cargar el video',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final video = snapshot.data!; // datos obtenidos API

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          // titulo
                          Text(
                            video.title, // titulo desde backend
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // boton de reproducir
                          ElevatedButton.icon(
                            onPressed: () {
                              // poner la direccion para reproducir video
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('REPRODUCIR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // los botones de añadir a lista y valoración
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              //  boton lists
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // hay que hacer que añada a la lista aún
                                    },
                                    icon: const Icon(
                                      Icons.menu,
                                      color: Colors.yellow,
                                      size: 30,
                                    ),
                                  ),
                                  const Text(
                                    'Añadir a lista',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // texto de valoración
                              Column(
                                children: const [
                                  Text(
                                    '*****',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 22,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Valoración',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          //  descripción del video
                          Text(
                            video.description, // descripcion desde backend
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 40,
            right: 15,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context); // volver a pantalla anterior
              },
            ),
          ),
        ],
      ),
    );
  }
}
