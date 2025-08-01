import 'package:floor/floor.dart';
import '../Entities/flight_entity.dart';

/// Data Access Object for the [Flight] entity.
@dao
abstract class FlightDao {
  /// Inserts a new [flight] into the database.
  @insert
  Future<int> insertFlight(Flight flight);

  /// Updates an existing [flight] in the database.
  @update
  Future<void> updateFlight(Flight flight);

  /// Retrieves all flights from the database.
  @Query('SELECT * FROM flights')
  Future<List<Flight>> findAllFlights();

  /// Deletes a [flight] from the database.
  @delete
  Future<void> deleteFlight(Flight flight);
}