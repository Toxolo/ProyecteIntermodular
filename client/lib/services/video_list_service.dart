import 'package:client/data/local/daos/lists_dao.dart';
import '../data/local/app_database.dart';

class VideoListService {
  final ListsDao _listsDao;

  VideoListService(this._listsDao);

  /// Obtenir totes les llistes
  Future<List<VideoList>> getAllLists() async {
    return await _listsDao.getAllLists();
  }

  /// Crear nova llista
  Future<void> createList(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('El nom de la llista no pot estar buit');
    }
    await _listsDao.createList(name);
  }

  /// Afegir un vídeo a una llista
  Future<void> addVideoToList({required int listId, required int videoId}) async {
    final exists = await _listsDao.isVideoInList(listId: listId, videoId: videoId);
    if (!exists) {
      await _listsDao.addVideoToList(listId: listId, videoId: videoId);
    }
  }

  /// Treure un vídeo d'una llista
  Future<void> removeVideoFromList({required int listId, required int videoId}) async {
    final exists = await _listsDao.isVideoInList(listId: listId, videoId: videoId);
    if (exists) {
      await _listsDao.removeVideoFromList(listId: listId, videoId: videoId);
    }
  }

  /// Obtenir IDs de llistes que contenen un vídeo (per checkboxes)
  Future<Set<int>> getListsContainingVideo(int videoId) async {
    final allLists = await _listsDao.getAllLists();
    final result = <int>{};
    for (var list in allLists) {
      final contains = await _listsDao.isVideoInList(listId: list.id, videoId: videoId);
      if (contains) result.add(list.id);
    }
    return result;
  }

  /// Eliminar una llista
  Future<void> deleteList(int listId) async {
    await _listsDao.deleteList(listId);
  }

}
