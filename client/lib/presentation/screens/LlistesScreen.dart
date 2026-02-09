import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import '../catalog_styles.dart';
import 'videos_de_llista_page.dart';

// Pantalla que muestra todas las listas creadas por el usuario
class LlistesScreen extends StatefulWidget {
  final AppDatabase db;

  const LlistesScreen({super.key, required this.db});

  @override
  State<LlistesScreen> createState() => _LlistesScreenState();
}

class _LlistesScreenState extends State<LlistesScreen> {
  // Lista de listas obtenidas de la base de datos
  List<VideoList> _llistes = [];

  // Controla si estamos cargando datos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Carga las listas al abrir la pantalla
    _loadLlistes();
  }

  // Carga todas las listas desde la base de datos local
  Future<void> _loadLlistes() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Consulta al DAO de listas
      final llistes = await widget.db.listsDao.getAllLists();

      if (mounted) {
        setState(() {
          _llistes = llistes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Podrías mostrar un mensaje de error aquí en el futuro
    }
  }

  // Muestra diálogo de confirmación y elimina una lista
  Future<void> _deleteList(VideoList llista) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Confirmar eliminació',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Segur que vols eliminar la llista "${llista.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel·lar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Solo borramos si el usuario confirmó
    if (confirm == true && mounted) {
      await widget.db.listsDao.deleteList(llista.id);

      // Mensajito de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Llista "${llista.name}" eliminada')),
      );

      // Recargamos la lista para reflejar el cambio
      _loadLlistes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,

      appBar: AppBar(
        backgroundColor: CatalogStyles.backgroundBlack,
        foregroundColor: Colors.white,
        title: const Text('Llistes'),
        actions: [
          // Botón para recargar manualmente (útil si se editan listas desde otra pantalla)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLlistes,
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // Decide qué mostrar: cargando, vacío o lista de listas
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_llistes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.list_alt, color: Colors.white38, size: 64),
            SizedBox(height: 16),
            Text(
              'Cap llista creada',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Afegix vídeos a llistes des de la pantalla de vídeo',
              style: TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Lista scrollable con todas las listas del usuario
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: _llistes.length,
      itemBuilder: (context, index) {
        final llista = _llistes[index];
        return _buildListTile(llista);
      },
    );
  }

  // Cada elemento de la lista: nombre + botón borrar + clic para ver contenido
  Widget _buildListTile(VideoList llista) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      leading: const Icon(Icons.playlist_play, color: Colors.yellow),

      title: Text(
        llista.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => _deleteList(llista),
      ),

      onTap: () {
        // Abre la pantalla que muestra los vídeos de esta lista concreta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideosDeLlistaPage(db: widget.db, llista: llista),
          ),
        );
      },
    );
  }
}
