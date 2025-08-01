import 'package:floor/floor.dart';

@Entity(tableName: 'customers')
class Customer {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String firstName;
  String lastName;
  String address;
  int dateOfBirth;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dateOfBirth,
  });

  @override
  String toString() {
    return 'Customer: $firstName $lastName, Address: $address';
  }
}