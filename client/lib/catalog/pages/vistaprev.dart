import 'package:flutter/material.dart';
import '../catalog_styles.dart';
import 'catalog_page.dart';

class VistaPrev extends StatelessWidget {
  const VistaPrev({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,

      body: Column(
        children: [

          Container(
            height: 220, // altura para la imagen
            width: double.infinity,
            color: Colors.cyan, // azul (quitar cuando pongamos ya la img)
            child: const Center(),// Más adelante aquí ira la Imagen
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
                    // Volver al catalogo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CatalogPage(),
                      ),
                    );
                  },
                ),
              ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // titulo
                  const Text(
                    'Título',
                    style: TextStyle(
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
                  const Text('Descripción de video',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}