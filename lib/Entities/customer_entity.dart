import 'package:floor/floor.dart';

/// Represents a customer entity in the database.
@Entity(tableName: 'customers')
class Customer {
  /// The unique identifier for the customer.
  @PrimaryKey(autoGenerate: true)
  int? id;

  /// The first name of the customer.
  String firstName;
  /// The last name of the customer.
  String lastName;
  /// The address of the customer.
  String address;
  /// The customer's date of birth, stored as milliseconds since epoch.
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