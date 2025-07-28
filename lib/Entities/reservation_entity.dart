import 'package:floor/floor.dart';

@entity
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String customer;
  final String flight;
  final String date;
  final String comment;

  Reservation({
    this.id,
    required this.customer,
    required this.flight,
    required this.date,
    required this.comment,
  });
}
