import 'package:floor/floor.dart';
import '../Entities/reservation_entity.dart';

/// Data Access Object for the [Reservation] entity.
@dao
abstract class ReservationDao {
  /// Retrieves all reservations from the database.
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> getAllReservations();

  /// Inserts a new [reservation] into the database.
  @insert
  Future<int> insertReservation(Reservation reservation);

  /// Deletes a [reservation] from the database.
  @delete
  Future<void> deleteReservation(Reservation reservation);

  /// Deletes all reservations from the database.
  @Query('DELETE FROM Reservation')
  Future<void> deleteAll();
}