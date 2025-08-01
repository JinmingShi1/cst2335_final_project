import 'package:floor/floor.dart';

import '../Entities/customer_entity.dart';

/// Data Access Object for the [Customer] entity.
@dao
abstract class CustomerDao {
  /// Retrieves all customers from the database, ordered by name.
  @Query('SELECT * FROM customers ORDER BY firstName, lastName')
  Future<List<Customer>> findAllCustomers();

  /// Inserts a new [customer] into the database.
  @insert
  Future<int> insertCustomer(Customer customer);

  /// Updates an existing [customer] in the database.
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a [customer] from the database.
  @delete
  Future<void> deleteCustomer(Customer customer);
}