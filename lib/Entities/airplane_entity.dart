import 'package:floor/floor.dart';

/// Represents an airplane entity in the database.
@Entity(tableName: 'airplanes')
class Airplane {
  /// The unique identifier for the airplane.
  @PrimaryKey(autoGenerate: true)
  int? id;

  /// The model or type of the airplane (e.g., "Boeing 777").
  String type;
  /// The maximum number of passengers the airplane can carry.
  int passengerCapacity;
  /// The maximum speed of the airplane in km/h.
  int maxSpeed;
  /// The maximum flight distance of the airplane in km.
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