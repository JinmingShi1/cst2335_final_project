// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airplane_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AirplaneDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AirplaneDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AirplaneDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AirplaneDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAirplaneDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AirplaneDatabaseBuilderContract databaseBuilder(String name) =>
      _$AirplaneDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AirplaneDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AirplaneDatabaseBuilder(null);
}

class _$AirplaneDatabaseBuilder implements $AirplaneDatabaseBuilderContract {
  _$AirplaneDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AirplaneDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AirplaneDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AirplaneDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AirplaneDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AirplaneDatabase extends AirplaneDatabase {
  _$AirplaneDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AirplaneDao? _airplaneDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `airplanes` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` TEXT NOT NULL, `passengerCapacity` INTEGER NOT NULL, `maxSpeed` INTEGER NOT NULL, `range` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AirplaneDao get airplaneDao {
    return _airplaneDaoInstance ??= _$AirplaneDao(database, changeListener);
  }
}

class _$AirplaneDao extends AirplaneDao {
  _$AirplaneDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'airplanes',
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'passengerCapacity': item.passengerCapacity,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                }),
        _airplaneUpdateAdapter = UpdateAdapter(
            database,
            'airplanes',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'passengerCapacity': item.passengerCapacity,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                }),
        _airplaneDeletionAdapter = DeletionAdapter(
            database,
            'airplanes',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'passengerCapacity': item.passengerCapacity,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final UpdateAdapter<Airplane> _airplaneUpdateAdapter;

  final DeletionAdapter<Airplane> _airplaneDeletionAdapter;

  @override
  Future<List<Airplane>> findAllAirplanes() async {
    return _queryAdapter.queryList('SELECT * FROM airplanes',
        mapper: (Map<String, Object?> row) => Airplane(
            id: row['id'] as int?,
            type: row['type'] as String,
            passengerCapacity: row['passengerCapacity'] as int,
            maxSpeed: row['maxSpeed'] as int,
            range: row['range'] as int));
  }

  @override
  Future<int> insertAirplane(Airplane airplane) {
    return _airplaneInsertionAdapter.insertAndReturnId(
        airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAirplane(Airplane airplane) async {
    await _airplaneUpdateAdapter.update(airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAirplane(Airplane airplane) async {
    await _airplaneDeletionAdapter.delete(airplane);
  }
}
