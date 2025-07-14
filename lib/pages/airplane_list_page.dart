import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/airplane_dao.dart';
import '../database/airplane_database.dart';
import '../Entities/airplane_entity.dart';
import '../localization/AppLocalizations.dart';

class AirplaneListPage extends StatefulWidget {
  const AirplaneListPage({super.key});

  @override
  State<AirplaneListPage> createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  late AirplaneDao dao;
  List<Airplane> airplanes = [];

  final _typeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _speedController = TextEditingController();
  final _rangeController = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  Airplane? _selectedAirplane;

  @override
  void initState() {
    super.initState();
    _initDB();

    // add listeners to all the fields
    _typeController.addListener(_saveInput);
    _capacityController.addListener(_saveInput);
    _speedController.addListener(_saveInput);
    _rangeController.addListener(_saveInput);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _capacityController.dispose();
    _speedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  Future<void> _initDB() async {
    final db = await $FloorAirplaneDatabase.databaseBuilder('airplanes.db').build();
    dao = db.airplaneDao;

    final useLast = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Use Previous Data?"),
        content: const Text("Do you want to reuse last airplane form input?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (useLast ?? false) {
      _typeController.text = await _secureStorage.read(key: 'last_type') ?? '';
      _capacityController.text = await _secureStorage.read(key: 'last_capacity') ?? '';
      _speedController.text = await _secureStorage.read(key: 'last_speed') ?? '';
      _rangeController.text = await _secureStorage.read(key: 'last_range') ?? '';
    } else {
      _clearInput();
    }

    _loadAirplanes();
  }

  Future<void> _loadAirplanes() async {
    final list = await dao.findAllAirplanes();
    setState(() {
      airplanes = list;
    });
  }

  Future<void> _addAirplane() async {
    if (_formNotValid()) return;

    final airplane = Airplane(
      type: _typeController.text,
      passengerCapacity: int.parse(_capacityController.text),
      maxSpeed: int.parse(_speedController.text),
      range: int.parse(_rangeController.text),
    );

    final insertedId = await dao.insertAirplane(airplane);
    airplane.id = insertedId;

    await _saveInput();

    setState(() {
      airplanes.add(airplane);
      _clearForm();
    });

    _showSnackBar("Airplane added");
  }

  Future<void> _updateAirplane() async {
    if (_formNotValid() || _selectedAirplane == null) return;

    final updated = Airplane(
      id: _selectedAirplane!.id,
      type: _typeController.text,
      passengerCapacity: int.parse(_capacityController.text),
      maxSpeed: int.parse(_speedController.text),
      range: int.parse(_rangeController.text),
    );

    await dao.updateAirplane(updated);

    await _saveInput();

    setState(() {
      final index = airplanes.indexWhere((a) => a.id == updated.id);
      if (index != -1) airplanes[index] = updated;
      _clearForm();
    });

    _showSnackBar("Airplane updated");
  }

  void _confirmDeleteAirplane() {
    if (_selectedAirplane == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete?"),
        content: Text("Delete airplane: ${_selectedAirplane!.type}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dao.deleteAirplane(_selectedAirplane!);
              setState(() {
                airplanes.removeWhere((a) => a.id == _selectedAirplane!.id);
                _clearForm();
              });
              _showSnackBar("Airplane deleted");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  bool _formNotValid() {
    if (_typeController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _speedController.text.isEmpty ||
        _rangeController.text.isEmpty) {
      _showSnackBar("All fields must be filled");
      return true;
    }
    return false;
  }

  void _clearForm() {
    _typeController.clear();
    _capacityController.clear();
    _speedController.clear();
    _rangeController.clear();
    _selectedAirplane = null;
  }

  Future<void> _saveInput() async {
    await _secureStorage.write(key: 'last_type', value: _typeController.text);
    await _secureStorage.write(key: 'last_capacity', value: _capacityController.text);
    await _secureStorage.write(key: 'last_speed', value: _speedController.text);
    await _secureStorage.write(key: 'last_range', value: _rangeController.text);
  }

  Future<void> _clearInput() async {
    await _secureStorage.deleteAll();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("airplaneListTitle") ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("How to use"),
                  content: Text(t.translate('howToUseContent') ?? ''),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _typeController, decoration: const InputDecoration(labelText: 'Type'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _capacityController, decoration: const InputDecoration(labelText: 'Capacity'))),
          ]),
          Row(children: [
            Expanded(child: TextField(controller: _speedController, decoration: const InputDecoration(labelText: 'Speed'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _rangeController, decoration: const InputDecoration(labelText: 'Range'))),
          ]),
          const SizedBox(height: 16),
          _selectedAirplane == null
              ? ElevatedButton(onPressed: _addAirplane, child: const Text("Add Airplane"))
              : Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: _updateAirplane, child: const Text("Update"))),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _confirmDeleteAirplane,
                  child: const Text("Delete"),
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: airplanes.length,
              itemBuilder: (context, index) {
                final airplane = airplanes[index];
                return ListTile(
                  title: Text(airplane.type),
                  subtitle: Text("Capacity: ${airplane.passengerCapacity}, Speed: ${airplane.maxSpeed}, Range: ${airplane.range}"),
                  onTap: () {
                    setState(() {
                      _selectedAirplane = airplane;
                      _typeController.text = airplane.type;
                      _capacityController.text = airplane.passengerCapacity.toString();
                      _speedController.text = airplane.maxSpeed.toString();
                      _rangeController.text = airplane.range.toString();
                    });
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
