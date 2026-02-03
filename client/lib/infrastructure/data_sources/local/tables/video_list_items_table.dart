import 'package:drift/drift.dart';

class VideoListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer()();
  IntColumn get videoId => integer()();
}
