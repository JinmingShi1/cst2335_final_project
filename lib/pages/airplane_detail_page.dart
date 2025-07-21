import 'package:flutter/material.dart';
import '../dao/airplane_dao.dart';
import '../Entities/airplane_entity.dart';
import '../localization/AppLocalizations.dart';

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
  late AppLocalizations t;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
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
        title: Text(t.translate("Delete")),
        content: Text("${t.translate("airplaneListConfirmDelete")} ${widget.airplane.type}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate("Cancel")),
          ),
          TextButton(
            onPressed: () async {
              await widget.dao.deleteAirplane(widget.airplane);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("airplaneListDeleted"))));
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: Text(t.translate("Delete"), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${t.translate("Edit")}: ${widget.airplane.type}"),
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
                decoration: InputDecoration(labelText: t.translate("Type")),
                validator: (value) => value!.isEmpty ? "${t.translate("airplaneListPleaseEnter")} ${t.translate("Type")}" : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(labelText: t.translate("Capacity")),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "${t.translate("airplaneListPleaseEnter")} ${t.translate("Capacity")}" : null,
              ),
              TextFormField(
                controller: _speedController,
                decoration: InputDecoration(labelText: "${t.translate("airplaneListMaxSpeed")} (km/h)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "${t.translate("airplaneListPleaseEnter")} ${t.translate("Speed")}" : null,
              ),
              TextFormField(
                controller: _rangeController,
                decoration: InputDecoration(labelText: "${t.translate("Range")} (km)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "${t.translate("airplaneListPleaseEnter")} ${t.translate("Range")}" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateAirplane,
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