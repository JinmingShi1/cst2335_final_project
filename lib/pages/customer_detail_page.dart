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

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _dobCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.customer.firstName);
    _lastNameCtrl = TextEditingController(text: widget.customer.lastName);
    _addressCtrl = TextEditingController(text: widget.customer.address);
    _dobCtrl = TextEditingController(text: _formatDate(widget.customer.dateOfBirth));
  }

  String _formatDate(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String().substring(0, 10);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (pickedDate != null) {
      setState(() {
        _dobCtrl.text = pickedDate.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _onUpdatePressed() async {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = Customer(
        id: widget.customer.id,
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        address: _addressCtrl.text,
        dateOfBirth: DateTime.parse(_dobCtrl.text).millisecondsSinceEpoch,
      );

      await widget.dao.updateCustomer(updatedCustomer);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("customerListCustomerUpdated"))));
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _onDeletePressed() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.translate("Delete")),
        content: Text("${t.translate("customerListConfirmDelete")} ${_firstNameCtrl.text} ${_lastNameCtrl.text}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.translate("Cancel"))),
          TextButton(
            onPressed: () async {
              await widget.dao.deleteCustomer(widget.customer);
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("customerListCustomerDeleted"))));
                Navigator.pop(context);
                Navigator.pop(context, true);
              }
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
        title: Text("${t.translate("Edit")}: ${_firstNameCtrl.text}"),
        backgroundColor: Colors.teal,
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _onDeletePressed)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: InputDecoration(labelText: t.translate("customerListFirstName"), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.person_outline)),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: InputDecoration(labelText: t.translate("customerListLastName"), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.person_outline)),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(labelText: t.translate("customerListAddress"), border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.home_outlined)),
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _dobCtrl,
                decoration: InputDecoration(
                    labelText: t.translate("customerListDob"),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: _pickDate,
                    )
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? t.translate("customerListPleaseEnter") : null,
              ),
              const SizedBox(height: 30),
              OutlinedButton.icon(
                icon: const Icon(Icons.save_as_outlined),
                onPressed: _onUpdatePressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.teal),
                  foregroundColor: Colors.teal,
                ),
                label: Text(t.translate("Update")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}