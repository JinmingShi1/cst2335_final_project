import 'package:floor/floor.dart';
import '../Entities/reservation_entity.dart';

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> getAllReservations();

  @insert
  Future<int> insertReservation(Reservation reservation);

  @Query('DELETE FROM Reservation WHERE id = :id')
  Future<void> deleteReservationById(int id);

  @Query('DELETE FROM Reservation')
  Future<void> deleteAll();
}
