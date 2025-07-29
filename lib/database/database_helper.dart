

import '../model/customer.dart';
import 'app_database.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static AppDatabase? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<AppDatabase> get database async {
    _database ??= await $FloorAppDatabase
        .databaseBuilder('customers.db')
        .build();
    return _database!;
  }

  Future<List<Customer>> getCustomers() async =>
      (await database).customerDao.findAllCustomers();

  Future<int> insertCustomer(Customer customer) async =>
      (await database).customerDao.insertCustomer(customer);

  Future<void> updateCustomer(Customer customer) async =>
      (await database).customerDao.updateCustomer(customer);

  Future<void> deleteCustomer(Customer customer) async =>
      (await database).customerDao.deleteCustomer(customer);
}
