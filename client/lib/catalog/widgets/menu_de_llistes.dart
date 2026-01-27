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
  Set<int> selectedListIds = {};

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  void _refreshLists() async {
    _llistesFuture = widget.service.getAllLists();
    final listsWithVideo = await widget.service.getListsContainingVideo(widget.videoId);
    setState(() {
      selectedListIds = listsWithVideo.toSet();
    });
  }

  void _toggleList(VideoList list, bool selected) async {
    if (selected) {
      await widget.service.addVideoToList(listId: list.id, videoId: widget.videoId);
      setState(() => selectedListIds.add(list.id));
    } else {
      await widget.service.removeVideoFromList(listId: list.id, videoId: widget.videoId);
      setState(() => selectedListIds.remove(list.id));
    }
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Nova llista', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nom de la llista',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar', style: TextStyle(color: Colors.yellow)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await widget.service.createList(controller.text.trim());
              Navigator.pop(context);
              _refreshLists();
            },
            child: const Text('Crear', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
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
            const Text(
              'Afegir a llista',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                      final selected = selectedListIds.contains(llista.id);

                      return CheckboxListTile(
                        title: Text(llista.name, style: const TextStyle(color: Colors.white)),
                        value: selected,
                        onChanged: (value) {
                          if (value != null) _toggleList(llista, value);
                        },
                        activeColor: Colors.yellow,
                        checkColor: Colors.black,
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
