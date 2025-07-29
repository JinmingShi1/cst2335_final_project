import 'package:flutter/material.dart';
import '../dao/customer_dao.dart';
import '../database/app_database.dart';
import '../model/customer.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late CustomerDao dao;
  List<Customer> customers = [];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  Future<void> _initDB() async {
    final db = await $FloorAppDatabase.databaseBuilder('app.db').build();
    dao = db.customerDao;
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final list = await dao.findAllCustomers();
    setState(() {
      customers = list;
    });
  }

  Future<void> _addCustomer() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    final customer = Customer(
      name: _nameController.text,
      email: _emailController.text, firstName: '', lastName: '', address: '', dateOfBirth: 12,
    );

    final id = await dao.insertCustomer(customer);
    customer.id = id;

    setState(() {
      customers.add(customer);
      _nameController.clear();
      _emailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Customer added")),
    );
  }

  void _deleteCustomer(int index) {
    final customer = customers[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Customer"),
        content: Text("Delete ${customer.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dao.deleteCustomer(customer);
              setState(() {
                customers.removeAt(index);
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer List")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'))),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _addCustomer, child: const Text("Add Customer")),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(Customer.email),
                  onLongPress: () => _deleteCustomer(index),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
