import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../dao/flight_dao.dart'; // Make sure the path is correct
import '../Entities/flight_entity.dart'; // Make sure the path is correct

part 'flight_database.g.dart';

@Database(version: 1, entities: [Flight])
abstract class FlightDatabase extends FloorDatabase {
  FlightDao get flightDao;
}