import 'package:floor/floor.dart';

@entity
class Customer {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String firstName;
  final String lastName;
  final String address;
  final int dateOfBirth;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dateOfBirth, required String name, required String email,
  });

  factory Customer.withDateTime({
    int? id,
    required String firstName,

    required String lastName,
    required String address,
    required DateTime dateOfBirth,
  }) {
    return Customer(
      id: id,
      firstName: firstName,
      lastName: lastName,
      address: address,
      dateOfBirth: dateOfBirth.millisecondsSinceEpoch, name: '', email: '',
    );
  }

  String get fullName => '$firstName $lastName';
  DateTime get birthDate => DateTime.fromMillisecondsSinceEpoch(dateOfBirth);

  get name => null;

  String? get email => null;

  String? get customer => null;
}
