import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/airplane_dao.dart';
import '../database/airplane_database.dart';
import '../Entities/airplane_entity.dart';
import '../localization/AppLocalizations.dart';
import 'airplane_detail_page.dart';

class AirplaneListPage extends StatefulWidget {
  const AirplaneListPage({super.key});

  @override
  State<AirplaneListPage> createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  late AirplaneDao dao;
  List<Airplane> airplanes = [];

  // For the "Add" form
  final _addFormTypeController = TextEditingController();
  final _addFormCapacityController = TextEditingController();
  final _addFormSpeedController = TextEditingController();
  final _addFormRangeController = TextEditingController();

  // For the tablet's detail view form
  final _detailFormKey = GlobalKey<FormState>();
  final _detailFormTypeController = TextEditingController();
  final _detailFormCapacityController = TextEditingController();
  final _detailFormSpeedController = TextEditingController();
  final _detailFormRangeController = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  Airplane? _selectedAirplane;

  @override
  void initState() {
    super.initState();
    _initDB();

    // Listeners for the "Add" form to save input
    _addFormTypeController.addListener(_saveInput);
    _addFormCapacityController.addListener(_saveInput);
    _addFormSpeedController.addListener(_saveInput);
    _addFormRangeController.addListener(_saveInput);
  }

  @override
  void dispose() {
    _addFormTypeController.dispose();
    _addFormCapacityController.dispose();
    _addFormSpeedController.dispose();
    _addFormRangeController.dispose();

    _detailFormTypeController.dispose();
    _detailFormCapacityController.dispose();
    _detailFormSpeedController.dispose();
    _detailFormRangeController.dispose();
    super.dispose();
  }

  Future<void> _initDB() async {
    final db = await $FloorAirplaneDatabase.databaseBuilder('airplanes.db').build();
    dao = db.airplaneDao;

    Future.delayed(Duration.zero, () async {
      final useLast = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Use Previous Data?"),
          content: const Text("Do you want to reuse the last 'Add' form input?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
          ],
        ),
      );

      if (useLast ?? false) {
        await _loadSavedInput();
      } else {
        await _clearSavedInput();
      }
    });

    _loadAirplanes();
  }

  Future<void> _saveInput() async {
    await _secureStorage.write(key: 'last_type', value: _addFormTypeController.text);
    await _secureStorage.write(key: 'last_capacity', value: _addFormCapacityController.text);
    await _secureStorage.write(key: 'last_speed', value: _addFormSpeedController.text);
    await _secureStorage.write(key: 'last_range', value: _addFormRangeController.text);
  }

  Future<void> _loadSavedInput() async {
    _addFormTypeController.text = await _secureStorage.read(key: 'last_type') ?? '';
    _addFormCapacityController.text = await _secureStorage.read(key: 'last_capacity') ?? '';
    _addFormSpeedController.text = await _secureStorage.read(key: 'last_speed') ?? '';
    _addFormRangeController.text = await _secureStorage.read(key: 'last_range') ?? '';
  }

  Future<void> _clearSavedInput() async {
    await _secureStorage.deleteAll();
  }

  Future<void> _loadAirplanes() async {
    final list = await dao.findAllAirplanes();
    setState(() {
      airplanes = list;
    });
  }

  Future<void> _addAirplane() async {
    if (_addFormTypeController.text.isEmpty ||
        _addFormCapacityController.text.isEmpty ||
        _addFormSpeedController.text.isEmpty ||
        _addFormRangeController.text.isEmpty) {
      _showSnackBar("All fields must be filled to add an airplane");
      return;
    }

    final airplane = Airplane(
      type: _addFormTypeController.text,
      passengerCapacity: int.parse(_addFormCapacityController.text),
      maxSpeed: int.parse(_addFormSpeedController.text),
      range: int.parse(_addFormRangeController.text),
    );

    await dao.insertAirplane(airplane);
    _clearAddForm();
    await _clearSavedInput();
    _loadAirplanes();
    _showSnackBar("Airplane added");
  }

  void _clearAddForm() {
    _addFormTypeController.clear();
    _addFormCapacityController.clear();
    _addFormSpeedController.clear();
    _addFormRangeController.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Phone Navigation
  Future<void> _navigateToDetail(Airplane airplane) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirplaneDetailPage(airplane: airplane, dao: dao),
      ),
    );

    if (result == true) {
      _loadAirplanes();
    }
  }

  // Tablet Detail View
  void _selectAirplaneForTablet(Airplane airplane) {
    setState(() {
      _selectedAirplane = airplane;

      _detailFormTypeController.text = airplane.type;
      _detailFormCapacityController.text = airplane.passengerCapacity.toString();
      _detailFormSpeedController.text = airplane.maxSpeed.toString();
      _detailFormRangeController.text = airplane.range.toString();
    });
  }

  Future<void> _updateAirplaneFromTablet() async {
    if (_selectedAirplane == null) return;

    if (_detailFormKey.currentState!.validate()) {
      final updatedAirplane = Airplane(
        id: _selectedAirplane!.id,
        type: _detailFormTypeController.text,
        passengerCapacity: int.parse(_detailFormCapacityController.text),
        maxSpeed: int.parse(_detailFormSpeedController.text),
        range: int.parse(_detailFormRangeController.text),
      );
      await dao.updateAirplane(updatedAirplane);
      _showSnackBar("Airplane Updated");
      // Refresh list and clear selection
      _loadAirplanes();
      setState(() {
        _selectedAirplane = null;
      });
    }
  }

  Future<void> _deleteAirplaneFromTablet() async {
    if (_selectedAirplane == null) return;

    await dao.deleteAirplane(_selectedAirplane!);
    _showSnackBar("Airplane Deleted");
    _loadAirplanes();
    setState(() {
      _selectedAirplane = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("airplaneListTitle") ?? 'Airplane List'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use different layout for phone and tablet
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
    return Column(
      children: [
        _buildAddAirplaneForm(),
        const Divider(),
        _buildAirplaneList((airplane) {
          _navigateToDetail(airplane);
        }),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildAddAirplaneForm(),
              const Divider(),
              _buildAirplaneList((airplane) {
                _selectAirplaneForTablet(airplane);
              }),
            ],
          ),
        ),
        const VerticalDivider(),
        // Right side: Detail view
        Expanded(
          flex: 3,
          child: _selectedAirplane == null
              ? const Center(child: Text("Select an airplane to see details"))
              : _buildTabletDetailView(),
        ),
      ],
    );
  }

  Widget _buildAddAirplaneForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Add New Airplane", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _addFormTypeController, decoration: const InputDecoration(labelText: 'Type'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _addFormCapacityController, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number)),
          ]),
          Row(children: [
            Expanded(child: TextField(controller: _addFormSpeedController, decoration: const InputDecoration(labelText: 'Speed'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _addFormRangeController, decoration: const InputDecoration(labelText: 'Range'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addAirplane,
            child: const Text("Add New Airplane"),
          )
        ],
      ),
    );
  }

  Widget _buildAirplaneList(void Function(Airplane) onTap) {
    return Expanded(
      child: ListView.builder(
        itemCount: airplanes.length,
        itemBuilder: (context, index) {
          final airplane = airplanes[index];
          return ListTile(
            title: Text(airplane.type),
            subtitle: Text("Capacity: ${airplane.passengerCapacity}, Speed: ${airplane.maxSpeed}, Range: ${airplane.range}"),
            trailing: const Icon(Icons.chevron_right),
            selected: _selectedAirplane?.id == airplane.id,
            onTap: () => onTap(airplane),
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
            Text("Edit: ${_selectedAirplane!.type}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _detailFormTypeController,
              decoration: const InputDecoration(labelText: 'Type'),
              validator: (value) => value!.isEmpty ? 'Please enter a type' : null,
            ),
            TextFormField(
              controller: _detailFormCapacityController,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter a capacity' : null,
            ),
            TextFormField(
              controller: _detailFormSpeedController,
              decoration: const InputDecoration(labelText: 'Max Speed (km/h)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter a speed' : null,
            ),
            TextFormField(
              controller: _detailFormRangeController,
              decoration: const InputDecoration(labelText: 'Range (km)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter a range' : null,
            ),
            const Spacer(), // Pushes buttons to the bottom
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateAirplaneFromTablet,
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteAirplaneFromTablet,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: (){
              setState(() {
                _selectedAirplane = null;
              });
            }, child: const Text("Clear Selection"))
          ],
        ),
      ),
    );
  }
}