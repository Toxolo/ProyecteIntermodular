// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_dao.dart';

// ignore_for_file: type=lint
mixin _$ListsDaoMixin on DatabaseAccessor<AppDatabase> {
  $VideoListsTable get videoLists => attachedDatabase.videoLists;
  $VideoListItemsTable get videoListItems => attachedDatabase.videoListItems;
  ListsDaoManager get managers => ListsDaoManager(this);
}

class ListsDaoManager {
  final _$ListsDaoMixin _db;
  ListsDaoManager(this._db);
  $$VideoListsTableTableManager get videoLists =>
      $$VideoListsTableTableManager(_db.attachedDatabase, _db.videoLists);
  $$VideoListItemsTableTableManager get videoListItems =>
      $$VideoListItemsTableTableManager(
        _db.attachedDatabase,
        _db.videoListItems,
      );
}
