import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/customer_dao.dart';
import '../Entities/customer_entity.dart';

part 'customer_database.g.dart';

@Database(version: 1, entities: [Customer])
abstract class CustomerDatabase extends FloorDatabase {
  CustomerDao get customerDao;
}
