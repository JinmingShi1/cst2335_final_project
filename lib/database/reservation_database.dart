import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite; // ✅ 加上这行
import 'dart:async';

import '../Entities/reservation_entity.dart';
import '../Entities/flight_entity.dart';

import '../dao/ReservationDao.dart';
import '../dao/flight_dao.dart';

part 'reservation_database.g.dart'; // ✅ Floor 会生成这个文件

@Database(
  version: 1,
  entities: [Reservation, Flight],
)
abstract class ReservationDatabase extends FloorDatabase {
  ReservationDao get reservationDao;
  FlightDao get flightDao; // ✅ Floor 会为这个生成实现
}
