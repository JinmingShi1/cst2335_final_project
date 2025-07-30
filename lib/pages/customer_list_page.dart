import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/customer_dao.dart';
import '../database/customer_database.dart';
import '../Entities/customer_entity.dart';
import '../localization/AppLocalizations.dart';
import 'customer_detail_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late AppLocalizations t;
  late CustomerDao dao;
  List<Customer> customers = [];

  final _addFirstNameCtrl = TextEditingController();
  final _addLastNameCtrl = TextEditingController();
  final _addAddressCtrl = TextEditingController();
  final _addDobCtrl = TextEditingController();

  final _detailFormKey = GlobalKey<FormState>();
  final _detailFirstNameCtrl = TextEditingController();
  final _detailLastNameCtrl = TextEditingController();
  final _detailAddressCtrl = TextEditingController();
  final _detailDobCtrl = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _initDB();

    _addFirstNameCtrl.addListener(_saveInput);
    _addLastNameCtrl.addListener(_saveInput);
    _addAddressCtrl.addListener(_saveInput);
    _addDobCtrl.addListener(_saveInput);
  }

  @override
  void dispose() {
    _addFirstNameCtrl.dispose();
    _addLastNameCtrl.dispose();
    _addAddressCtrl.dispose();
    _addDobCtrl.dispose();
    _detailFirstNameCtrl.dispose();
    _detailLastNameCtrl.dispose();
    _detailAddressCtrl.dispose();
    _detailDobCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  Future<void> _initDB() async {
    final db = await $FloorCustomerDatabase.databaseBuilder('customer_database.db').build();
    dao = db.customerDao;

    Future.delayed(Duration.zero, () async {
      final useLast = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.translate("customerListUsePreviousData")),
          content: Text(t.translate("customerListReuseLastInput")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.translate("No"))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.translate("Yes"))),
          ],
        ),
      );

      if (useLast == true) {
        await _loadSavedInput();
      } else {
        await _clearSavedInput();
      }
    });

    _loadCustomers();
  }

  Future<void> _saveInput() async {
    await _secureStorage.write(key: 'last_firstName', value: _addFirstNameCtrl.text);
    await _secureStorage.write(key: 'last_lastName', value: _addLastNameCtrl.text);
    await _secureStorage.write(key: 'last_address', value: _addAddressCtrl.text);
    await _secureStorage.write(key: 'last_dob', value: _addDobCtrl.text);
  }

  Future<void> _loadSavedInput() async {
    _addFirstNameCtrl.text = await _secureStorage.read(key: 'last_firstName') ?? '';
    _addLastNameCtrl.text = await _secureStorage.read(key: 'last_lastName') ?? '';
    _addAddressCtrl.text = await _secureStorage.read(key: 'last_address') ?? '';
    _addDobCtrl.text = await _secureStorage.read(key: 'last_dob') ?? '';
  }

  Future<void> _clearSavedInput() async {
    await _secureStorage.deleteAll();
  }

  Future<void> _loadCustomers() async {
    final list = await dao.findAllCustomers();
    setState(() {
      customers = list;
    });
  }

  Future<void> _addCustomer() async {
    if (_addFirstNameCtrl.text.isEmpty ||
        _addLastNameCtrl.text.isEmpty ||
        _addAddressCtrl.text.isEmpty ||
        _addDobCtrl.text.isEmpty) {
      _showSnackBar(t.translate("customerListFormNotice"));
      return;
    }

    final customer = Customer(
      firstName: _addFirstNameCtrl.text,
      lastName: _addLastNameCtrl.text,
      address: _addAddressCtrl.text,
      dateOfBirth: DateTime.tryParse(_addDobCtrl.text)?.millisecondsSinceEpoch ?? 0,
    );

    await dao.insertCustomer(customer);
    _clearAddForm();
    await _clearSavedInput();
    _loadCustomers();
    _showSnackBar(t.translate("customerListCustomerAdded"));
  }

  void _clearAddForm() {
    _addFirstNameCtrl.clear();
    _addLastNameCtrl.clear();
    _addAddressCtrl.clear();
    _addDobCtrl.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _navigateToDetail(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer, dao: dao),
      ),
    );
    if (result == true) {
      _loadCustomers();
    }
  }

  void _selectCustomerForTablet(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _detailFirstNameCtrl.text = customer.firstName;
      _detailLastNameCtrl.text = customer.lastName;
      _detailAddressCtrl.text = customer.address;
      _detailDobCtrl.text = DateTime.fromMillisecondsSinceEpoch(customer.dateOfBirth).toIso8601String().substring(0, 10);
    });
  }

  Future<void> _updateCustomerFromTablet() async {
    if (_selectedCustomer == null) return;

    if (_detailFormKey.currentState!.validate()) {
      final updatedCustomer = Customer(
        id: _selectedCustomer!.id,
        firstName: _detailFirstNameCtrl.text,
        lastName: _detailLastNameCtrl.text,
        address: _detailAddressCtrl.text,
        dateOfBirth: DateTime.tryParse(_detailDobCtrl.text)?.millisecondsSinceEpoch ?? _selectedCustomer!.dateOfBirth,
      );
      await dao.updateCustomer(updatedCustomer);
      _showSnackBar(t.translate("customerListCustomerUpdated"));
      _loadCustomers();
      setState(() => _selectedCustomer = null);
    }
  }

  Future<void> _deleteCustomerFromTablet() async {
    if (_selectedCustomer == null) return;
    await dao.deleteCustomer(_selectedCustomer!);
    _showSnackBar(t.translate("customerListCustomerDeleted"));
    _loadCustomers();
    setState(() => _selectedCustomer = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("customerListTitle")),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t.translate("customerListHowToUse")),
                  content: Text(t.translate("customerListHowToUseContent")),
                  actions: [TextButton(child: Text(t.translate("OK")), onPressed: () => Navigator.of(context).pop())],
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 720) {
            return _buildTabletLayout();
          } else {
            return _buildPhoneLayout();
          }
        },
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [_buildAddCustomerForm(), const Divider(), _buildCustomerList(_navigateToDetail)],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 450,
          child: Column(
            children: [
              _buildAddCustomerForm(),
              const Divider(),
              _buildCustomerList(_selectCustomerForTablet),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: _selectedCustomer == null
              ? Center(child: Text(t.translate("customerListSelectToSeeDetails")))
              : _buildTabletDetailView(),
        ),
      ],
    );
  }

  Widget _buildAddCustomerForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.translate("customerListAddCustomer"), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(controller: _addFirstNameCtrl, decoration: InputDecoration(labelText: t.translate("customerListFirstName"))),
          TextField(controller: _addLastNameCtrl, decoration: InputDecoration(labelText: t.translate("customerListLastName"))),
          TextField(controller: _addAddressCtrl, decoration: InputDecoration(labelText: t.translate("customerListAddress"))),
          TextField(controller: _addDobCtrl, decoration: InputDecoration(labelText: t.translate("customerListDob"), hintText: "YYYY-MM-DD")),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addCustomer,
            child: Text(t.translate("customerListAddCustomer")),
          )
        ],
      ),
    );
  }

  Widget _buildCustomerList(void Function(Customer) onTap) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5, // Constrain height
      child: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return ListTile(
            title: Text("${customer.firstName} ${customer.lastName}"),
            subtitle: Text(customer.address),
            trailing: const Icon(Icons.chevron_right),
            selected: _selectedCustomer?.id == customer.id,
            onTap: () => onTap(customer),
          );
        },
      ),
    );
  }

  Widget _buildTabletDetailView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _detailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("${t.translate("Edit")}: ${_selectedCustomer!.firstName}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _detailFirstNameCtrl,
              decoration: InputDecoration(labelText: t.translate("customerListFirstName")),
              validator: (v) => v!.isEmpty ? t.translate("customerListPleaseEnter") : null,
            ),
            TextFormField(
              controller: _detailLastNameCtrl,
              decoration: InputDecoration(labelText: t.translate("customerListLastName")),
              validator: (v) => v!.isEmpty ? t.translate("customerListPleaseEnter") : null,
            ),
            TextFormField(
              controller: _detailAddressCtrl,
              decoration: InputDecoration(labelText: t.translate("customerListAddress")),
              validator: (v) => v!.isEmpty ? t.translate("customerListPleaseEnter") : null,
            ),
            TextFormField(
              controller: _detailDobCtrl,
              decoration: InputDecoration(labelText: t.translate("customerListDob")),
              validator: (v) => v!.isEmpty ? t.translate("customerListPleaseEnter") : null,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _updateCustomerFromTablet, child: Text(t.translate("Update")))),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteCustomerFromTablet,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(t.translate("Delete")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}