import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../Entities/reservation_entity.dart';
import '../dao/ReservationDao.dart';

part 'reservation_database.g.dart'; // generated code

@Database(version: 1, entities: [Reservation])
abstract class ReservationDatabase extends FloorDatabase {
  ReservationDao get reservationDao;
}
