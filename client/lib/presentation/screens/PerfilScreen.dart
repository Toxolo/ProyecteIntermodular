import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:client/presentation/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../catalog_styles.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key, db});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
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
                    Text(
                      ref.read(userProvider).getName(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Tancar Sessio
            InkWell(
              onTap: () {
                ref.read(userProvider).clearTokens();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Cerrar Sesion',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
