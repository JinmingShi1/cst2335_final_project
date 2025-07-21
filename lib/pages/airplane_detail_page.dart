import 'package:flutter/material.dart';
import '../dao/airplane_dao.dart';
import '../Entities/airplane_entity.dart';

/// An editable detail page for a single airplane.
class AirplaneDetailPage extends StatefulWidget {
  final Airplane airplane;
  final AirplaneDao dao;

  const AirplaneDetailPage({
    super.key,
    required this.airplane,
    required this.dao,
  });

  @override
  State<AirplaneDetailPage> createState() => _AirplaneDetailPageState();
}

class _AirplaneDetailPageState extends State<AirplaneDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _capacityController;
  late TextEditingController _speedController;
  late TextEditingController _rangeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the airplane's current data.
    _typeController = TextEditingController(text: widget.airplane.type);
    _capacityController = TextEditingController(text: widget.airplane.passengerCapacity.toString());
    _speedController = TextEditingController(text: widget.airplane.maxSpeed.toString());
    _rangeController = TextEditingController(text: widget.airplane.range.toString());
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed.
    _typeController.dispose();
    _capacityController.dispose();
    _speedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  Future<void> _updateAirplane() async {
    if (_formKey.currentState!.validate()) {
      final updatedAirplane = Airplane(
        id: widget.airplane.id,
        type: _typeController.text,
        passengerCapacity: int.parse(_capacityController.text),
        maxSpeed: int.parse(_speedController.text),
        range: int.parse(_rangeController.text),
      );

      await widget.dao.updateAirplane(updatedAirplane);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Airplane Updated")));
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete?"),
        content: Text("Are you sure you want to delete ${widget.airplane.type}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await widget.dao.deleteAirplane(widget.airplane);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Airplane Deleted")));
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit: ${widget.airplane.type}"),
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
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) => value!.isEmpty ? 'Please enter a type' : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a capacity' : null,
              ),
              TextFormField(
                controller: _speedController,
                decoration: const InputDecoration(labelText: 'Max Speed (km/h)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a speed' : null,
              ),
              TextFormField(
                controller: _rangeController,
                decoration: const InputDecoration(labelText: 'Range (km)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a range' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateAirplane,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Update Airplane'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}