import 'package:floor/floor.dart';
import '../Entities/flight_entity.dart';

@dao
abstract class FlightDao {
  @insert
  Future<int> insertFlight(Flight flight);

  @update
  Future<void> updateFlight(Flight flight);

  @Query('SELECT * FROM flights')
  Future<List<Flight>> findAllFlights();

  @delete
  Future<void> deleteFlight(Flight flight);
}