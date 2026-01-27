import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/video_lists_table.dart';
import '../tables/video_list_items_table.dart';

part 'lists_dao.g.dart';

@DriftAccessor(tables: [VideoLists, VideoListItems])
class ListsDao extends DatabaseAccessor<AppDatabase> with _$ListsDaoMixin {
  ListsDao(AppDatabase db) : super(db);

  // ─── Llistes ───
  Future<int> createList(String name) =>
      into(videoLists).insert(VideoListsCompanion(name: Value(name)));

  Future<List<VideoList>> getAllLists() => select(videoLists).get();

  Future<VideoList?> getListById(int id) =>
      (select(videoLists)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ─── Vídeos ───
  Future<int> addVideoToList({required int listId, required int videoId}) =>
      into(videoListItems).insert(VideoListItemsCompanion(
        listId: Value(listId),
        videoId: Value(videoId),
      ));

  Future<List<VideoListItem>> getVideosInList(int listId) =>
      (select(videoListItems)..where((t) => t.listId.equals(listId))).get();

  Future<bool> isVideoInList({required int listId, required int videoId}) async {
    final query = await (select(videoListItems)
          ..where((t) => t.listId.equals(listId) & t.videoId.equals(videoId)))
        .get();
    return query.isNotEmpty;
  }

  Future<void> removeVideoFromList({required int listId, required int videoId}) async {
    await (delete(videoListItems)
          ..where((t) => t.listId.equals(listId) & t.videoId.equals(videoId)))
        .go();
  }

  /// Retorna totes les llistes que contenen un vídeo
  Future<List<VideoList>> getListsContainingVideo(int videoId) async {
    final query = await (select(videoLists).join([
      innerJoin(
        videoListItems,
        videoListItems.listId.equalsExp(videoLists.id),
      )
    ])
          ..where(videoListItems.videoId.equals(videoId)))
        .get();

    // Extraiem només les llistes
    return query.map((row) => row.readTable(videoLists)).toList();
  }

  Future<void> deleteList(int listId) async {
    await (delete(videoLists)..where((t) => t.id.equals(listId))).go();
    // També eliminem tots els vídeos d’aquesta llista
    await (delete(videoListItems)..where((t) => t.listId.equals(listId))).go();
  }

}
