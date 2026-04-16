import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/captains_dao.dart';
import 'daos/publishers_dao.dart';
import 'daos/territories_dao.dart';
import 'daos/blocks_dao.dart';
import 'daos/preaching_days_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

// ══════════════════════════════════════════
//  TABLAS
// ══════════════════════════════════════════

class Captains extends Table {
  TextColumn get id          => text()();
  TextColumn get name        => text()();
  TextColumn get phone       => text().nullable()();
  TextColumn get email       => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Publishers extends Table {
  TextColumn get id          => text()();
  TextColumn get name        => text()();
  TextColumn get phone       => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Territories extends Table {
  TextColumn get id          => text()();
  TextColumn get name        => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Blocks extends Table {
  TextColumn get id           => text()();
  TextColumn get blockNumber  => text()();
  TextColumn get status       => text().withDefault(const Constant('PENDING'))();
  TextColumn get notes        => text().nullable()();
  TextColumn get territoryId  => text().references(Territories, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PreachingDays extends Table {
  TextColumn get id          => text()();
  DateTimeColumn get date    => dateTime()();
  TextColumn get captainId   => text().references(Captains, #id)();
  TextColumn get notes       => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PreachingParticipants extends Table {
  TextColumn get id              => text()();
  TextColumn get preachingDayId  => text().references(PreachingDays, #id)();
  TextColumn get publisherId     => text().references(Publishers, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class PreachedBlocks extends Table {
  TextColumn get id              => text()();
  TextColumn get preachingDayId  => text().references(PreachingDays, #id)();
  TextColumn get blockId         => text().references(Blocks, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id          => text()();
  TextColumn get entity      => text()(); // 'publisher','captain', etc
  TextColumn get operation   => text()(); // 'CREATE','UPDATE','DELETE'
  TextColumn get payload     => text()(); // JSON del objeto
  IntColumn  get attempts    => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ══════════════════════════════════════════
//  BASE DE DATOS
// ══════════════════════════════════════════

@DriftDatabase(tables: [
  Captains,
  Publishers,
  Territories,
  Blocks,
  PreachingDays,
  PreachingParticipants,
  PreachedBlocks,
  SyncQueue,
], daos: [
  CaptainsDao,
  PublishersDao,
  TerritoriesDao,
  BlocksDao,
  PreachingDaysDao,
  SyncQueueDao,
])

class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'preaching_db');
  }

  CaptainsDao      get captainsDao      => CaptainsDao(this);
  PublishersDao    get publishersDao    => PublishersDao(this);
  TerritoriesDao   get territoriesDao   => TerritoriesDao(this);
  BlocksDao        get blocksDao        => BlocksDao(this);
  PreachingDaysDao get preachingDaysDao => PreachingDaysDao(this);
  SyncQueueDao get syncQueueDao => SyncQueueDao(this);
}