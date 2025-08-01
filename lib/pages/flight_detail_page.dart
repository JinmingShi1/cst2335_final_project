import 'package:flutter/material.dart';
import '../dao/flight_dao.dart';
import '../Entities/flight_entity.dart';
import '../localization/AppLocalizations.dart';

class FlightDetailPage extends StatefulWidget {
  final Flight flight;
  final FlightDao dao;

  const FlightDetailPage({
    super.key,
    required this.flight,
    required this.dao,
  });

  @override
  State<FlightDetailPage> createState() => _FlightDetailPageState();
}

class _FlightDetailPageState extends State<FlightDetailPage> {
  late AppLocalizations t;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController departureCityCtrl;
  late TextEditingController destinationCityCtrl;
  late TextEditingController departureTimeCtrl;
  late TextEditingController arrivalTimeCtrl;

  @override
  void initState() {
    super.initState();
    departureCityCtrl = TextEditingController(text: widget.flight.departureCity);
    destinationCityCtrl = TextEditingController(text: widget.flight.destinationCity);
    departureTimeCtrl = TextEditingController(text: widget.flight.departureTime);
    arrivalTimeCtrl = TextEditingController(text: widget.flight.arrivalTime);
  }

  @override
  void dispose() {
    departureCityCtrl.dispose();
    destinationCityCtrl.dispose();
    departureTimeCtrl.dispose();
    arrivalTimeCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final updatedFlight = Flight(
        id: widget.flight.id,
        departureCity: departureCityCtrl.text,
        destinationCity: destinationCityCtrl.text,
        departureTime: departureTimeCtrl.text,
        arrivalTime: arrivalTimeCtrl.text,
      );

      await widget.dao.updateFlight(updatedFlight);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.translate("flightListFlightUpdated")))
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleDelete() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.translate("Delete")),
        content: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(dialogContext).style,
            children: <TextSpan>[
              TextSpan(text: "${t.translate("flightListConfirmDelete")} "),
              TextSpan(text: "${widget.flight.departureCity} -> ${widget.flight.destinationCity}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: "?"),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.translate("Cancel"))
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.dao.deleteFlight(widget.flight);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.translate("flightListFlightDeleted")))
                );
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t.translate("Delete")),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${t.translate("Edit")}: ${widget.flight.departureCity}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDelete,
            tooltip: t.translate("Delete"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStyledTextFormField(controller: departureCityCtrl, label: t.translate("flightListDepartureCity")),
                _buildStyledTextFormField(controller: destinationCityCtrl, label: t.translate("flightListDestinationCity")),
                _buildStyledTextFormField(controller: departureTimeCtrl, label: t.translate("flightListDepartureTime")),
                _buildStyledTextFormField(controller: arrivalTimeCtrl, label: t.translate("flightListArrivalTime")),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(t.translate("Update")),
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}