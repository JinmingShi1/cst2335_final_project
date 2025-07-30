import 'package:flutter/material.dart';
import '../dao/customer_dao.dart';
import '../Entities/customer_entity.dart';
import '../localization/AppLocalizations.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  final CustomerDao dao;

  const CustomerDetailPage({
    super.key,
    required this.customer,
    required this.dao,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late AppLocalizations t;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.customer.firstName);
    _lastNameController = TextEditingController(text: widget.customer.lastName);
    _addressController = TextEditingController(text: widget.customer.address);
    // Display date in a readable format
    _dobController = TextEditingController(
        text: DateTime.fromMillisecondsSinceEpoch(widget.customer.dateOfBirth)
            .toIso8601String()
            .substring(0, 10));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  Future<void> _updateCustomer() async {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = Customer(
        id: widget.customer.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        address: _addressController.text,
        // For simplicity, we parse the date back. A real app would use a date picker.
        dateOfBirth: DateTime.tryParse(_dobController.text)?.millisecondsSinceEpoch ?? widget.customer.dateOfBirth,
      );

      await widget.dao.updateCustomer(updatedCustomer);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("customerListCustomerUpdated"))));
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.translate("Delete")),
        content: Text(
            "${t.translate("customerListConfirmDelete")} ${widget.customer.firstName} ${widget.customer.lastName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate("Cancel")),
          ),
          TextButton(
            onPressed: () async {
              await widget.dao.deleteCustomer(widget.customer);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("customerListCustomerDeleted"))));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Go back to list
            },
            child: Text(t.translate("Delete"), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${t.translate("Edit")}: ${widget.customer.firstName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: t.translate("customerListFirstName")),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: t.translate("customerListLastName")),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: t.translate("customerListAddress")),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: t.translate("customerListDob"), hintText: "YYYY-MM-DD"),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateCustomer,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: Text(t.translate("Update")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}