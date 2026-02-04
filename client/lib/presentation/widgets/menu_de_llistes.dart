import 'package:client/infrastructure/data_sources/ApiService.dart';
import 'package:flutter/material.dart';
import '../../infrastructure/data_sources/local/app_database.dart';

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
  late Future<List<VideoList>> _listsFuture;
  Set<int> _selectedListIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() {
      _listsFuture = widget.service.getAllLists();
    });

    try {
      final listsWithVideo = await widget.service.getListsContainingVideo(
        widget.videoId,
      );
      if (mounted) {
        setState(() {
          _selectedListIds = listsWithVideo;
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _toggleList(VideoList list, bool selected) async {
    setState(() => _isLoading = true);

    try {
      if (selected) {
        await widget.service.addVideoToList(
          listId: list.id,
          videoId: widget.videoId,
        );
        if (mounted) {
          setState(() => _selectedListIds.add(list.id));
        }
      } else {
        await widget.service.removeVideoFromList(
          listId: list.id,
          videoId: widget.videoId,
        );
        if (mounted) {
          setState(() => _selectedListIds.remove(list.id));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Nova llista', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nom de la llista',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.yellow),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel·lar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nom no pot estar buit')),
                );
                return;
              }

              try {
                await widget.service.createList(name);
                if (mounted) {
                  Navigator.pop(dialogContext);
                  _loadLists();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Llista "$name" creada')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
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
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle indicator
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            const Text(
              'Afegir a llista',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Lists
            Expanded(
              child: FutureBuilder<List<VideoList>>(
                future: _listsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Cap llista creada',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final lists = snapshot.data!;

                  return ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      final isSelected = _selectedListIds.contains(list.id);

                      return CheckboxListTile(
                        title: Text(
                          list.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: isSelected,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  _toggleList(list, value);
                                }
                              },
                        activeColor: Colors.yellow,
                        checkColor: Colors.black,
                        tileColor: Colors.transparent,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Create new list button
            ElevatedButton.icon(
              onPressed: _showCreateListDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Crear nova llista'),
            ),
          ],
        ),
      ),
    );
  }
}
