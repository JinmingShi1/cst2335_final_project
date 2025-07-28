import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../Entities/reservation_entity.dart';
import '../dao/reservation_dao.dart';

//part 'reservationDatabase.g.dart'; // generated code

@Database(version: 1, entities: [Reservation])
abstract class ReservationDatabase extends FloorDatabase {
  ReservationDao get reservationDao;
}
