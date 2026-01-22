import 'package:flutter/material.dart';
import '../../data/local/app_database.dart';
import '../../services/video_list_service.dart';

class AddToListBottomSheet extends StatefulWidget {
  final VideoListService service;
  final int videoId;

  const AddToListBottomSheet({
    super.key,
    required this.service,
    required this.videoId,
  });

  @override
  State<AddToListBottomSheet> createState() => _AddToListBottomSheetState();
}

class _AddToListBottomSheetState extends State<AddToListBottomSheet> {
  late Future<List<VideoList>> _llistesFuture;

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  void _refreshLists() {
    _llistesFuture = widget.service.getAllLists();
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova llista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nom de la llista'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.service.createList(controller.text);
                Navigator.pop(context);
                setState(() => _refreshLists());
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<VideoList>>(
                future: _llistesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final llistes = snapshot.data!;
                  if (llistes.isEmpty) return const Center(child: Text('Cap llista creada', style: TextStyle(color: Colors.white)));

                  return ListView.builder(
                    itemCount: llistes.length,
                    itemBuilder: (context, index) {
                      final llista = llistes[index];
                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          title: Text(llista.name, style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.add, color: Colors.yellow),
                            onPressed: () async {
                              try {
                                await widget.service.addVideoToList(listId: llista.id, videoId: widget.videoId);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Vídeo afegit a la llista')));
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _showCreateListDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.yellow,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Crear nova llista'),
            ),
          ],
        ),
      ),
    );
  }
}
