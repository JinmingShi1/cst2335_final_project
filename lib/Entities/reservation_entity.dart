import 'package:floor/floor.dart';

/// Represents a reservation entity in the database.
@Entity(tableName: 'Reservation')
class Reservation {
  /// The unique identifier for the reservation.
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// The name of the customer for the reservation.
  final String customer;
  /// A description or ID of the flight for the reservation.
  final String flight;
  /// The date of the flight for the reservation.
  final String date;
  /// An optional comment or name for the reservation.
  final String comment;

  Reservation({
    this.id,
    required this.customer,
    required this.flight,
    required this.date,
    required this.comment,
  });
}