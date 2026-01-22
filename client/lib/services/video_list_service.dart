import 'package:client/data/local/daos/lists_dao.dart';
import '../data/local/app_database.dart';

class VideoListService {
  final ListsDao _listsDao;

  VideoListService(this._listsDao);

  /// Obtenir totes les llistes
  Future<List<VideoList>> getAllLists() async {
    return await _listsDao.getAllLists();
  }

  /// Crear una nova llista amb nom
  Future<void> createList(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('El nom de la llista no pot estar buit');
    }
    await _listsDao.createList(name);
  }

  /// Afegir un vídeo a una llista
  Future<void> addVideoToList({required int listId, required int videoId}) async {
    final exists = await _listsDao.isVideoInList(listId: listId, videoId: videoId);
    if (exists) {
      throw Exception('El vídeo ja està en aquesta llista');
    }
    await _listsDao.addVideoToList(listId: listId, videoId: videoId);
  }
}
