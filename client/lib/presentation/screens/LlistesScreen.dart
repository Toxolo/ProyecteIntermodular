import 'package:flutter/material.dart';
import 'package:client/infrastructure/data_sources/local/app_database.dart';
import '../catalog_styles.dart';
import 'videos_de_llista_page.dart';

class LlistesScreen extends StatefulWidget {
  final AppDatabase db;

  const LlistesScreen({super.key, required this.db});

  @override
  State<LlistesScreen> createState() => _LlistesScreenState();
}

class _LlistesScreenState extends State<LlistesScreen> {
  List<VideoList> _llistes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLlistes();
  }

  Future<void> _loadLlistes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
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
    }
  }

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

    if (confirm == true && mounted) {
      await widget.db.listsDao.deleteList(llista.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Llista "${llista.name}" eliminada')),
      );
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLlistes,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

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

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: _llistes.length,
      itemBuilder: (context, index) {
        final llista = _llistes[index];
        return _buildListTile(llista);
      },
    );
  }

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
