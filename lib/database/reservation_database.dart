import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite; // ✅ 加上这行
import 'dart:async';

import '../Entities/reservation_entity.dart';
import '../Entities/flight_entity.dart';

import '../dao/reservation_dao.dart';
import '../dao/flight_dao.dart';

part 'reservation_database.g.dart';

@Database(
  version: 1,
  entities: [Reservation, Flight],
)
abstract class ReservationDatabase extends FloorDatabase {
  ReservationDao get reservationDao;
  FlightDao get flightDao;
}
