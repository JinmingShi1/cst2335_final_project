import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// Customer List Page for adding, viewing, updating, and deleting customers.
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _dob;

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isTablet = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadPreviousCustomer();
  }

  void _loadCustomers() async {
    final data = await DatabaseHelper.instance.getCustomers();
    setState(() => _customers = data);
  }

  void _loadPreviousCustomer() async {
    final previous = await SharedPrefs.loadLastCustomer();
    if (previous != null) {
      _showCopyDialog(previous);
    }
  }

  void _showCopyDialog(Customer previous) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Copy Previous Customer?'),
        content: const Text('Would you like to pre-fill the form with the last customer\'s data?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _firstNameController.text = previous.firstName;
              _lastNameController.text = previous.lastName;
              _addressController.text = previous.address;
              _dob = previous.dob;
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _saveCustomer() async {
    if (_formKey.currentState!.validate() && _dob != null) {
      final customer = Customer(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        address: _addressController.text,
        dob: _dob!,
      );
      await DatabaseHelper.instance.insertCustomer(customer);
      await SharedPrefs.saveLastCustomer(customer);
      _loadCustomers();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully')),
      );
    }
  }

  void _updateCustomer() async {
    if (_selectedCustomer != null && _formKey.currentState!.validate()) {
      final updated = Customer(
        id: _selectedCustomer!.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        address: _addressController.text,
        dob: _dob!,
      );
      await DatabaseHelper.instance.updateCustomer(updated);
      _loadCustomers();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated')),
      );
    }
  }

  void _deleteCustomer() async {
    if (_selectedCustomer != null) {
      await DatabaseHelper.instance.deleteCustomer(_selectedCustomer!.id!);
      _loadCustomers();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted')),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _dob = null;
    _selectedCustomer = null;
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _addressController.text = customer.address;
      _dob = customer.dob;
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Instructions'),
        content: const Text(
          'Use the form to add or update customers. Tap a customer to edit. Use the delete button to remove them.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: _isTablet ? 1 : 0,
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text('${customer.firstName} ${customer.lastName}'),
                  subtitle: Text(customer.address),
                  onTap: () => _selectCustomer(customer),
                );
              },
            ),
          ),
          Expanded(
            flex: _isTablet ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    ListTile(
                      title: Text(_dob == null
                          ? 'Select Date of Birth'
                          : DateFormat.yMMMd().format(_dob!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _dob = picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectedCustomer == null ? _saveCustomer : _updateCustomer,
                          child: Text(_selectedCustomer == null ? 'Add Customer' : 'Update'),
                        ),
                        const SizedBox(width: 16),
                        if (_selectedCustomer != null)
                          ElevatedButton(
                            onPressed: _deleteCustomer,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
