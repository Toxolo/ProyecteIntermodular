import 'package:flutter/material.dart';
import 'package:client/data/local/app_database.dart';
import '../catalog_styles.dart';
import '../widgets/bottom_bar.dart';
import 'videos_de_llista_page.dart';

class LlistesPage extends StatefulWidget {
  final AppDatabase db;

  const LlistesPage({super.key, required this.db});

  @override
  State<LlistesPage> createState() => _LlistesPageState();
}

class _LlistesPageState extends State<LlistesPage> {
  late Future<List<VideoList>> _llistesFuture;

  @override
  void initState() {
    super.initState();
    _refreshLlistes();
  }

  void _refreshLlistes() {
    _llistesFuture = widget.db.listsDao.getAllLists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatalogStyles.backgroundBlack,
      body: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png', height: 40),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<VideoList>>(
              future: _llistesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final llistes = snapshot.data!;
                if (llistes.isEmpty) {
                  return const Center(
                    child: Text('Cap llista creada',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return ListView.builder(
                  itemCount: llistes.length,
                  itemBuilder: (context, index) {
                    final llista = llistes[index];

                    return ListTile(
                      title: Text(
                        llista.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Anem a la pàgina de vídeos d’aquesta llista
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideosDeLlistaPage(
                              db: widget.db,
                              llista: llista,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Colors.black,
                              title: const Text(
                                'Confirmar eliminació',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                'Segur que vols eliminar la llista "${llista.name}"?',
                                style: const TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel·lar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Eliminar',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await widget.db.listsDao.deleteList(llista.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Llista "${llista.name}" eliminada'),
                              ),
                            );
                            _refreshLlistes(); // Recarreguem la llista
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: 0, db: widget.db),
    );
  }
}
