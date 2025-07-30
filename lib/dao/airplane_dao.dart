import 'package:floor/floor.dart';
import '../Entities/airplane_entity.dart';

@dao
abstract class AirplaneDao {
  @insert
  Future<int> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @Query('SELECT * FROM airplanes')
  Future<List<Airplane>> findAllAirplanes();

  @delete
  Future<void> deleteAirplane(Airplane airplane);
}
