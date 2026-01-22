import 'package:client/catalog/widgets/bottom_bar.dart';
import 'package:client/data/local/app_database.dart';
import 'package:flutter/material.dart';
import '../catalog_styles.dart';


class PerfilPage extends StatelessWidget {
  final AppDatabase db;

  const PerfilPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 40),

            // img y nombre de perfil
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37), // dorado
                    shape: BoxShape.circle,
                  ),
                  // luego cambiar por img
                ),

                const SizedBox(width: 16),

                Row(
                  children: [
                    const Text(
                      'Messi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // añadir aqui para que edite nombre perfil
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // infantil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Infantil',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Switch(
                  value: false,
                  onChanged: (value) {
                    //  switch preparar para cambiar a modo infantil
                  },
                  activeThumbColor: const Color(0xFFD4AF37),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // configuracion
            InkWell(
              onTap: () {
                // tiene que ir a configuración_page
              },
              child: Row(
                children: const [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Configuración',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // borrar perfil
            InkWell(
              onTap: () {
                // configurar el use delete perfil
              },
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Borrar Perfil',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Boton de perfiles
            InkWell(
              onTap: () {
                // hay que ponerle aqui para que vaya a perfiles_page
              },
              child: Row(
                children: const [
                  Icon(Icons.switch_account, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Perfiles',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // la barra de listas y catalogo
      bottomNavigationBar: BottomBar(currentIndex: 2, db: db), // perfil

    );
  }
}
