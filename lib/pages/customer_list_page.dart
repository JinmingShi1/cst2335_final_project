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
  late CustomerDao _dao;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    final db = await $FloorCustomerDatabase.databaseBuilder('customer_database.db').build();
    _dao = db.customerDao;
    _refreshCustomerList();
    _promptForSavedData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  Future<void> _refreshCustomerList() async {
    final customerList = await _dao.findAllCustomers();
    setState(() {
      _customers = customerList;
    });
  }

  void _showInstructionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate("customerListHowToUse")),
        content: Text(t.translate("customerListHowToUseContent")),
        actions: [TextButton(child: Text(t.translate("OK")), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }

  Future<void> _promptForSavedData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final useLast = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.translate("customerListUsePreviousData")),
          content: Text(t.translate("customerListReuseLastInput")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.translate("No"))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.translate("Yes"))),
          ],
        ),
      );

      if (useLast == true) {
        _showAddCustomerSheet(loadPrevious: true);
      }
    });
  }

  void _showAddCustomerSheet({bool loadPrevious = false}) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final dobCtrl = TextEditingController();

    if (loadPrevious) {
      _storage.read(key: 'last_firstName').then((v) => firstNameCtrl.text = v ?? '');
      _storage.read(key: 'last_lastName').then((v) => lastNameCtrl.text = v ?? '');
      _storage.read(key: 'last_address').then((v) => addressCtrl.text = v ?? '');
      _storage.read(key: 'last_dob').then((v) => dobCtrl.text = v ?? '');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.translate("customerListAddCustomer"), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(controller: firstNameCtrl, decoration: InputDecoration(labelText: t.translate("customerListFirstName"))),
            TextField(controller: lastNameCtrl, decoration: InputDecoration(labelText: t.translate("customerListLastName"))),
            TextField(controller: addressCtrl, decoration: InputDecoration(labelText: t.translate("customerListAddress"))),
            TextField(
                controller: dobCtrl,
                decoration: InputDecoration(
                    labelText: t.translate("customerListDob"),
                    hintText: "YYYY-MM-DD",
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                          if(picked != null) dobCtrl.text = picked.toIso8601String().substring(0, 10);
                        }
                    )
                )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
              child: Text(t.translate("customerListAddCustomer")),
              onPressed: () async {
                if(firstNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty || addressCtrl.text.isEmpty || dobCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("customerListFormNotice"))));
                  return;
                }
                final newCustomer = Customer(
                  firstName: firstNameCtrl.text,
                  lastName: lastNameCtrl.text,
                  address: addressCtrl.text,
                  dateOfBirth: DateTime.parse(dobCtrl.text).millisecondsSinceEpoch,
                );
                await _dao.insertCustomer(newCustomer);

                await _storage.write(key: 'last_firstName', value: firstNameCtrl.text);
                await _storage.write(key: 'last_lastName', value: lastNameCtrl.text);
                await _storage.write(key: 'last_address', value: addressCtrl.text);
                await _storage.write(key: 'last_dob', value: dobCtrl.text);

                Navigator.pop(ctx);
                _refreshCustomerList();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("customerListCustomerAdded"))));
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleCustomerTapForPhone(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerDetailPage(customer: customer, dao: _dao)),
    );
    if (result == true) {
      _refreshCustomerList();
    }
  }

  void _handleCustomerTapForTablet(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("customerListTitle")),
        backgroundColor: Colors.teal,
        actions: [IconButton(icon: const Icon(Icons.help_outline), onPressed: _showInstructionDialog)],
      ),
      body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      floatingActionButton: isTablet ? null : FloatingActionButton(
        onPressed: () => _showAddCustomerSheet(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return _customers.isEmpty
        ? Center(child: Text(t.translate("customerListNoCustomers")))
        : ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final customer = _customers[index];
        return _buildCustomerCard(customer, () => _handleCustomerTapForPhone(customer));
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(t.translate("customerListAddCustomer")),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => _showAddCustomerSheet(),
                ),
              ),
              const Divider(),
              Expanded(
                child: _customers.isEmpty
                    ? Center(child: Text(t.translate("customerListNoCustomers")))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return _buildCustomerCard(customer, () => _handleCustomerTapForTablet(customer));
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedCustomer == null
              ? Center(child: Text(t.translate("customerListSelectToSeeDetails")))
              : CustomerDetailPage(
            key: ValueKey(_selectedCustomer!.id), // Important for state reset
            customer: _selectedCustomer!,
            dao: _dao,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(Customer customer, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text("${customer.firstName[0]}${customer.lastName[0]}", style: const TextStyle(color: Colors.teal)),
        ),
        title: Text("${customer.firstName} ${customer.lastName}"),
        subtitle: Text(customer.address),
        onTap: onTap,
        selected: _selectedCustomer?.id == customer.id,
      ),
    );
  }
}