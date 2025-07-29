import 'package:flutter/material.dart';
import 'package:floor/floor.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'dart:async';



@entity
class Customer {
  @primaryKey
  final int? id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime dob;

  Customer({this.id, required this.firstName, required this.lastName, required this.address, required this.dob});
}

@dao
abstract class CustomerDao {
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getCustomers();

  @insert
  Future<void> insertCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);
}

@Database(version: 1, entities: [Customer])
abstract class AppDatabase extends FloorDatabase {
  CustomerDao get customerDao;
}
