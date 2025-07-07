import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/airplane_dao.dart';
import '../database/airplane_database.dart';
import '../Entities/airplane_entity.dart';

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

  @override
  void initState() {
    super.initState();
    _initDB();
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
    if (_typeController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _speedController.text.isEmpty ||
        _rangeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields must be filled")),
      );
      return;
    }

    final airplane = Airplane(
      type: _typeController.text,
      passengerCapacity: int.parse(_capacityController.text),
      maxSpeed: int.parse(_speedController.text),
      range: int.parse(_rangeController.text),
    );

    final insertedId = await dao.insertAirplane(airplane);
    airplane.id = insertedId;

    await _secureStorage.write(key: 'last_type', value: _typeController.text);
    await _secureStorage.write(key: 'last_capacity', value: _capacityController.text);
    await _secureStorage.write(key: 'last_speed', value: _speedController.text);
    await _secureStorage.write(key: 'last_range', value: _rangeController.text);

    setState(() {
      airplanes.add(airplane);
      _typeController.clear();
      _capacityController.clear();
      _speedController.clear();
      _rangeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Airplane added")));
  }

  void _deleteAirplane(int index) {
    final airplane = airplanes[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete?"),
        content: Text("Delete airplane: ${airplane.type}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dao.deleteAirplane(airplane);
              setState(() {
                airplanes.removeAt(index);
              });
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Airplane List")),
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
          ElevatedButton(onPressed: _addAirplane, child: const Text("Add Airplane")),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: airplanes.length,
              itemBuilder: (context, index) {
                final airplane = airplanes[index];
                return ListTile(
                  title: Text(airplane.type),
                  subtitle: Text("Capacity: ${airplane.passengerCapacity}, Speed: ${airplane.maxSpeed}, Range: ${airplane.range}"),
                  onLongPress: () => _deleteAirplane(index),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
