import 'package:floor/floor.dart';

@Entity(tableName: 'Reservation')
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
