import 'package:floor/floor.dart';

@Entity(tableName: 'airplanes')
class Airplane {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String type;
  int passengerCapacity;
  int maxSpeed;
  int range;

  Airplane({
    this.id,
    required this.type,
    required this.passengerCapacity,
    required this.maxSpeed,
    required this.range,
  });

  @override
  String toString() {
    return '$type, capacity: $passengerCapacity, speed: $maxSpeed km/h, range: $range km';
  }
}
