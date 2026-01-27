// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VideoListsTable extends VideoLists
    with TableInfo<$VideoListsTable, VideoList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VideoListsTable createAlias(String alias) {
    return $VideoListsTable(attachedDatabase, alias);
  }
}

class VideoList extends DataClass implements Insertable<VideoList> {
  final int id;
  final String name;
  final DateTime createdAt;
  const VideoList({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VideoListsCompanion toCompanion(bool nullToAbsent) {
    return VideoListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory VideoList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VideoList copyWith({int? id, String? name, DateTime? createdAt}) => VideoList(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  VideoList copyWithCompanion(VideoListsCompanion data) {
    return VideoList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class VideoListsCompanion extends UpdateCompanion<VideoList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const VideoListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VideoListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<VideoList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VideoListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return VideoListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VideoListItemsTable extends VideoListItems
    with TableInfo<$VideoListItemsTable, VideoListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<int> videoId = GeneratedColumn<int>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, listId, videoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoListItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoListItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}video_id'],
      )!,
    );
  }

  @override
  $VideoListItemsTable createAlias(String alias) {
    return $VideoListItemsTable(attachedDatabase, alias);
  }
}

class VideoListItem extends DataClass implements Insertable<VideoListItem> {
  final int id;
  final int listId;
  final int videoId;
  const VideoListItem({
    required this.id,
    required this.listId,
    required this.videoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['video_id'] = Variable<int>(videoId);
    return map;
  }

  VideoListItemsCompanion toCompanion(bool nullToAbsent) {
    return VideoListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      videoId: Value(videoId),
    );
  }

  factory VideoListItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoListItem(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      videoId: serializer.fromJson<int>(json['videoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'videoId': serializer.toJson<int>(videoId),
    };
  }

  VideoListItem copyWith({int? id, int? listId, int? videoId}) => VideoListItem(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    videoId: videoId ?? this.videoId,
  );
  VideoListItem copyWithCompanion(VideoListItemsCompanion data) {
    return VideoListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('videoId: $videoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, videoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.videoId == this.videoId);
}

class VideoListItemsCompanion extends UpdateCompanion<VideoListItem> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int> videoId;
  const VideoListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.videoId = const Value.absent(),
  });
  VideoListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required int videoId,
  }) : listId = Value(listId),
       videoId = Value(videoId);
  static Insertable<VideoListItem> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? videoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (videoId != null) 'video_id': videoId,
    });
  }

  VideoListItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<int>? videoId,
  }) {
    return VideoListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      videoId: videoId ?? this.videoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<int>(videoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('videoId: $videoId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideoListsTable videoLists = $VideoListsTable(this);
  late final $VideoListItemsTable videoListItems = $VideoListItemsTable(this);
  late final ListsDao listsDao = ListsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    videoLists,
    videoListItems,
  ];
}

typedef $$VideoListsTableCreateCompanionBuilder =
    VideoListsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$VideoListsTableUpdateCompanionBuilder =
    VideoListsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

class $$VideoListsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoListsTable> {
  $$VideoListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideoListsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoListsTable> {
  $$VideoListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideoListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoListsTable> {
  $$VideoListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VideoListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoListsTable,
          VideoList,
          $$VideoListsTableFilterComposer,
          $$VideoListsTableOrderingComposer,
          $$VideoListsTableAnnotationComposer,
          $$VideoListsTableCreateCompanionBuilder,
          $$VideoListsTableUpdateCompanionBuilder,
          (
            VideoList,
            BaseReferences<_$AppDatabase, $VideoListsTable, VideoList>,
          ),
          VideoList,
          PrefetchHooks Function()
        > {
  $$VideoListsTableTableManager(_$AppDatabase db, $VideoListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) =>
                  VideoListsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => VideoListsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideoListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoListsTable,
      VideoList,
      $$VideoListsTableFilterComposer,
      $$VideoListsTableOrderingComposer,
      $$VideoListsTableAnnotationComposer,
      $$VideoListsTableCreateCompanionBuilder,
      $$VideoListsTableUpdateCompanionBuilder,
      (VideoList, BaseReferences<_$AppDatabase, $VideoListsTable, VideoList>),
      VideoList,
      PrefetchHooks Function()
    >;
typedef $$VideoListItemsTableCreateCompanionBuilder =
    VideoListItemsCompanion Function({
      Value<int> id,
      required int listId,
      required int videoId,
    });
typedef $$VideoListItemsTableUpdateCompanionBuilder =
    VideoListItemsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<int> videoId,
    });

class $$VideoListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoListItemsTable> {
  $$VideoListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideoListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoListItemsTable> {
  $$VideoListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideoListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoListItemsTable> {
  $$VideoListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);
}

class $$VideoListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoListItemsTable,
          VideoListItem,
          $$VideoListItemsTableFilterComposer,
          $$VideoListItemsTableOrderingComposer,
          $$VideoListItemsTableAnnotationComposer,
          $$VideoListItemsTableCreateCompanionBuilder,
          $$VideoListItemsTableUpdateCompanionBuilder,
          (
            VideoListItem,
            BaseReferences<_$AppDatabase, $VideoListItemsTable, VideoListItem>,
          ),
          VideoListItem,
          PrefetchHooks Function()
        > {
  $$VideoListItemsTableTableManager(
    _$AppDatabase db,
    $VideoListItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int> videoId = const Value.absent(),
              }) => VideoListItemsCompanion(
                id: id,
                listId: listId,
                videoId: videoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required int videoId,
              }) => VideoListItemsCompanion.insert(
                id: id,
                listId: listId,
                videoId: videoId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideoListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoListItemsTable,
      VideoListItem,
      $$VideoListItemsTableFilterComposer,
      $$VideoListItemsTableOrderingComposer,
      $$VideoListItemsTableAnnotationComposer,
      $$VideoListItemsTableCreateCompanionBuilder,
      $$VideoListItemsTableUpdateCompanionBuilder,
      (
        VideoListItem,
        BaseReferences<_$AppDatabase, $VideoListItemsTable, VideoListItem>,
      ),
      VideoListItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideoListsTableTableManager get videoLists =>
      $$VideoListsTableTableManager(_db, _db.videoLists);
  $$VideoListItemsTableTableManager get videoListItems =>
      $$VideoListItemsTableTableManager(_db, _db.videoListItems);
}
