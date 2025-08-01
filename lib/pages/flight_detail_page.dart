import 'package:flutter/material.dart';
import '../dao/flight_dao.dart';
import '../Entities/flight_entity.dart';
import '../localization/AppLocalizations.dart';

/// A page for editing the details of a single flight.
class FlightDetailPage extends StatefulWidget {
  /// The flight to be edited.
  final Flight flight;
  /// The Data Access Object for flight database operations.
  final FlightDao dao;

  const FlightDetailPage({super.key, required this.flight, required this.dao});

  @override
  State<FlightDetailPage> createState() => _FlightDetailPageState();
}

/// State for the [FlightDetailPage].
class _FlightDetailPageState extends State<FlightDetailPage> {
  late AppLocalizations t;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _departureCityCtrl;
  late TextEditingController _destinationCityCtrl;
  late TextEditingController _departureTimeCtrl;
  late TextEditingController _arrivalTimeCtrl;

  @override
  void initState() {
    super.initState();
    _departureCityCtrl = TextEditingController(text: widget.flight.departureCity);
    _destinationCityCtrl = TextEditingController(text: widget.flight.destinationCity);
    _departureTimeCtrl = TextEditingController(text: widget.flight.departureTime);
    _arrivalTimeCtrl = TextEditingController(text: widget.flight.arrivalTime);
  }

  @override
  void dispose() {
    _departureCityCtrl.dispose();
    _destinationCityCtrl.dispose();
    _departureTimeCtrl.dispose();
    _arrivalTimeCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  /// Validates the form and updates the flight in the database.
  Future<void> _performUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedFlight = Flight(
      id: widget.flight.id,
      departureCity: _departureCityCtrl.text,
      destinationCity: _destinationCityCtrl.text,
      departureTime: _departureTimeCtrl.text,
      arrivalTime: _arrivalTimeCtrl.text,
    );
    await widget.dao.updateFlight(updatedFlight);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("flightListFlightUpdated"))));
      Navigator.pop(context, true);
    }
  }

  /// Shows a confirmation dialog before deleting the flight.
  Future<void> _performDelete() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.translate("Delete")),
        content: Text("${t.translate("flightListConfirmDelete")} ${widget.flight.departureCity}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.translate("Cancel"))),
          TextButton(
            onPressed: () async {
              await widget.dao.deleteFlight(widget.flight);
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("flightListFlightDeleted"))));
                Navigator.pop(ctx);
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
    final pageContent = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Route", style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  TextFormField(controller: _departureCityCtrl, decoration: InputDecoration(labelText: t.translate("flightListDepartureCity")), validator: (v) => v!.isEmpty ? "Required" : null),
                  TextFormField(controller: _destinationCityCtrl, decoration: InputDecoration(labelText: t.translate("flightListDestinationCity")), validator: (v) => v!.isEmpty ? "Required" : null),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Schedule", style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  TextFormField(controller: _departureTimeCtrl, decoration: InputDecoration(labelText: t.translate("flightListDepartureTime")), validator: (v) => v!.isEmpty ? "Required" : null),
                  TextFormField(controller: _arrivalTimeCtrl, decoration: InputDecoration(labelText: t.translate("flightListArrivalTime")), validator: (v) => v!.isEmpty ? "Required" : null),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _performDelete,
                child: Text(t.translate("Delete"), style: const TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: _performUpdate,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                child: Text(t.translate("Update")),
              ),
            ],
          )
        ],
      ),
    );

    if (Scaffold.maybeOf(context) != null) {
      return pageContent;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("${t.translate("Edit")}: ${widget.flight.departureCity}"),
          backgroundColor: Colors.deepOrange,
        ),
        body: pageContent,
      );
    }
  }
}