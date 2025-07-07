import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../dao/airplane_dao.dart';
import '../Entities/airplane_entity.dart';

part 'airplane_database.g.dart';

@Database(version: 1, entities: [Airplane])
abstract class AirplaneDatabase extends FloorDatabase {
  AirplaneDao get airplaneDao;
}
