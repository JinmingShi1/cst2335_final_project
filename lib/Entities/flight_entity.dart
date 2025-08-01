import 'package:floor/floor.dart';

/// Represents a flight entity in the database.
@Entity(tableName: 'flights')
class Flight {
  /// The unique identifier for the flight.
  @PrimaryKey(autoGenerate: true)
  int? id;

  /// The city from which the flight departs.
  String departureCity;
  /// The city where the flight arrives.
  String destinationCity;
  /// The scheduled departure time.
  String departureTime;
  /// The scheduled arrival time.
  String arrivalTime;

  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  @override
  String toString() {
    return '$departureCity to $destinationCity, departs at $departureTime';
  }
}