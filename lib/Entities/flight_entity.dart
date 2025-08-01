import 'package:floor/floor.dart';

@Entity(tableName: 'flights')
class Flight {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String departureCity;
  String destinationCity;
  String departureTime;
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