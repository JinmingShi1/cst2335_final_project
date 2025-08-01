import 'package:floor/floor.dart';

import '../Entities/customer_entity.dart';

@dao
abstract class CustomerDao {
  @Query('SELECT * FROM customers ORDER BY firstName, lastName')
  Future<List<Customer>> findAllCustomers();

  @insert
  Future<int> insertCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);
}
