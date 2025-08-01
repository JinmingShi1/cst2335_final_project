import 'package:floor/floor.dart';
import '../Entities/airplane_entity.dart';

/// Data Access Object for the [Airplane] entity.
@dao
abstract class AirplaneDao {
  /// Inserts a new [airplane] into the database.
  @insert
  Future<int> insertAirplane(Airplane airplane);

  /// Updates an existing [airplane] in the database.
  @update
  Future<void> updateAirplane(Airplane airplane);

  /// Retrieves all airplanes from the database.
  @Query('SELECT * FROM airplanes')
  Future<List<Airplane>> findAllAirplanes();

  /// Deletes an [airplane] from the database.
  @delete
  Future<void> deleteAirplane(Airplane airplane);
}