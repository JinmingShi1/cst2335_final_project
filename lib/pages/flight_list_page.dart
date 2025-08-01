import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/flight_dao.dart';
import '../database/flight_database.dart';
import '../Entities/flight_entity.dart';
import '../localization/AppLocalizations.dart';
import 'flight_detail_page.dart';

// A different theme color for this feature
const Color flightFeatureColor = Colors.blue;

class FlightListPage extends StatefulWidget {
  const FlightListPage({super.key});

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  // Using a different style for variable names for private state
  late FlightDao _dao;
  List<Flight> _flights = [];
  Flight? _selectedFlight;
  late AppLocalizations _t;

  // Grouping controllers for clarity
  final _addFormControllers = {
    'departureCity': TextEditingController(),
    'destinationCity': TextEditingController(),
    'departureTime': TextEditingController(),
    'arrivalTime': TextEditingController(),
  };

  final _detailFormKey = GlobalKey<FormState>();
  final _detailFormControllers = {
    'departureCity': TextEditingController(),
    'destinationCity': TextEditingController(),
    'departureTime': TextEditingController(),
    'arrivalTime': TextEditingController(),
  };

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _setupFormListeners();
  }

  // A different way to structure the init logic
  void _initializeDatabase() async {
    final db = await $FloorFlightDatabase.databaseBuilder('flights.db').build();
    _dao = db.flightDao;
    await _promptForPreviousData();
    _fetchFlights();
  }

  void _setupFormListeners() {
    _addFormControllers.forEach((key, controller) {
      controller.addListener(_handleFormChange);
    });
  }

  void _handleFormChange() {
    _saveInputToSecureStorage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _t = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _addFormControllers.forEach((_, controller) => controller.dispose());
    _detailFormControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchFlights() async {
    final flightList = await _dao.findAllFlights();
    setState(() {
      _flights = flightList;
    });
  }

  void _showStatusMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: flightFeatureColor),
    );
  }

  Future<void> _promptForPreviousData() async {
    // Using WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final useLast = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_t.translate("flightListUsePreviousData")),
          content: Text(_t.translate("flightListReuseLastInput")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_t.translate("No"))),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(_t.translate("Yes"))),
          ],
        ),
      );

      if (useLast == true) {
        await _loadInputFromSecureStorage();
      } else {
        await _storage.deleteAll();
      }
    });
  }

  Future<void> _saveInputToSecureStorage() async {
    await _storage.write(key: 'last_departure_city', value: _addFormControllers['departureCity']!.text);
    await _storage.write(key: 'last_destination_city', value: _addFormControllers['destinationCity']!.text);
    await _storage.write(key: 'last_departure_time', value: _addFormControllers['departureTime']!.text);
    await _storage.write(key: 'last_arrival_time', value: _addFormControllers['arrivalTime']!.text);
  }

  Future<void> _loadInputFromSecureStorage() async {
    _addFormControllers['departureCity']!.text = await _storage.read(key: 'last_departure_city') ?? '';
    _addFormControllers['destinationCity']!.text = await _storage.read(key: 'last_destination_city') ?? '';
    _addFormControllers['departureTime']!.text = await _storage.read(key: 'last_departure_time') ?? '';
    _addFormControllers['arrivalTime']!.text = await _storage.read(key: 'last_arrival_time') ?? '';
  }

  // Logic for adding a new flight
  void _onAddNewFlight() async {
    final departureCity = _addFormControllers['departureCity']!.text;
    final destinationCity = _addFormControllers['destinationCity']!.text;
    final departureTime = _addFormControllers['departureTime']!.text;
    final arrivalTime = _addFormControllers['arrivalTime']!.text;

    if (departureCity.isEmpty || destinationCity.isEmpty || departureTime.isEmpty || arrivalTime.isEmpty) {
      _showStatusMessage(_t.translate("flightListFormNotice"));
      return;
    }

    final newFlight = Flight(
      departureCity: departureCity,
      destinationCity: destinationCity,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
    );

    await _dao.insertFlight(newFlight);
    _showStatusMessage(_t.translate("flightListFlightAdded"));

    // Clear form and secure storage
    _addFormControllers.forEach((_, controller) => controller.clear());
    await _storage.deleteAll();
    _fetchFlights();
  }

  // Navigation logic
  void _goToDetailPage(Flight flight) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightDetailPage(flight: flight, dao: _dao),
      ),
    );
    if (result == true) {
      _fetchFlights();
      // On phone, after returning from detail, clear any tablet selection
      setState(() => _selectedFlight = null);
    }
  }

  void _handleFlightSelectionForTablet(Flight flight) {
    setState(() {
      _selectedFlight = flight;
      _detailFormControllers['departureCity']!.text = flight.departureCity;
      _detailFormControllers['destinationCity']!.text = flight.destinationCity;
      _detailFormControllers['departureTime']!.text = flight.departureTime;
      _detailFormControllers['arrivalTime']!.text = flight.arrivalTime;
    });
  }

  void _updateFlightFromTablet() async {
    if (_selectedFlight == null || !_detailFormKey.currentState!.validate()) return;

    final updatedFlight = Flight(
      id: _selectedFlight!.id,
      departureCity: _detailFormControllers['departureCity']!.text,
      destinationCity: _detailFormControllers['destinationCity']!.text,
      departureTime: _detailFormControllers['departureTime']!.text,
      arrivalTime: _detailFormControllers['arrivalTime']!.text,
    );

    await _dao.updateFlight(updatedFlight);
    _showStatusMessage(_t.translate("flightListFlightUpdated"));
    _fetchFlights();
    setState(() => _selectedFlight = null); // Clear selection after update
  }

  void _deleteFlightFromTablet() async {
    if (_selectedFlight == null) return;
    await _dao.deleteFlight(_selectedFlight!);
    _showStatusMessage(_t.translate("flightListFlightDeleted"));
    _fetchFlights();
    setState(() => _selectedFlight = null);
  }

  // Splitting UI into smaller builder functions
  Widget _buildPhoneLayout() {
    return Column(
      children: [
        _buildFlightCreatorCard(),
        const Divider(thickness: 1),
        _buildFlightsList(_goToDetailPage),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 450,
          child: Column(
            children: [
              _buildFlightCreatorCard(),
              const Divider(thickness: 1),
              _buildFlightsList(_handleFlightSelectionForTablet),
            ],
          ),
        ),
        const VerticalDivider(thickness: 1),
        Expanded(
          child: _selectedFlight == null
              ? Center(child: Text(_t.translate("flightListSelectToSeeDetails"), style: Theme.of(context).textTheme.headlineSmall))
              : _buildTabletDetailView(),
        ),
      ],
    );
  }

  Widget _buildFlightCreatorCard() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_t.translate("flightListAddFlight"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: flightFeatureColor)),
            const SizedBox(height: 16),
            TextField(controller: _addFormControllers['departureCity'], decoration: InputDecoration(labelText: _t.translate("flightListDepartureCity"), border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _addFormControllers['destinationCity'], decoration: InputDecoration(labelText: _t.translate("flightListDestinationCity"), border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _addFormControllers['departureTime'], decoration: InputDecoration(labelText: _t.translate("flightListDepartureTime"), border: const OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _addFormControllers['arrivalTime'], decoration: InputDecoration(labelText: _t.translate("flightListArrivalTime"), border: const OutlineInputBorder()))),
            ]),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onAddNewFlight,
              icon: const Icon(Icons.add),
              label: Text(_t.translate("flightListAddFlight")),
              style: ElevatedButton.styleFrom(
                backgroundColor: flightFeatureColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightsList(void Function(Flight) onFlightTap) {
    return Expanded(
      child: ListView.builder(
        itemCount: _flights.length,
        itemBuilder: (context, index) {
          final flight = _flights[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.flight_takeoff, color: flightFeatureColor),
              title: Text("${flight.departureCity} -> ${flight.destinationCity}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${_t.translate("flightListDepartureTime")}: ${flight.departureTime}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              selected: _selectedFlight?.id == flight.id,
              selectedTileColor: flightFeatureColor.withOpacity(0.1),
              onTap: () => onFlightTap(flight),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletDetailView() {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_t.translate("Edit")}: ${_selectedFlight!.departureCity}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false, // No back button
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteFlightFromTablet,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedFlight = null),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _detailFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _detailFormControllers['departureCity'], decoration: InputDecoration(labelText: _t.translate("flightListDepartureCity")), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 10),
              TextFormField(controller: _detailFormControllers['destinationCity'], decoration: InputDecoration(labelText: _t.translate("flightListDestinationCity")), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 10),
              TextFormField(controller: _detailFormControllers['departureTime'], decoration: InputDecoration(labelText: _t.translate("flightListDepartureTime")), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 10),
              TextFormField(controller: _detailFormControllers['arrivalTime'], decoration: InputDecoration(labelText: _t.translate("flightListArrivalTime")), validator: (v) => v!.isEmpty ? "Required" : null),
              const Spacer(),
              ElevatedButton(
                onPressed: _updateFlightFromTablet,
                style: ElevatedButton.styleFrom(backgroundColor: flightFeatureColor, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                child: Text(_t.translate("Update")),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t.translate("flightListTitle")),
        backgroundColor: flightFeatureColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(_t.translate("flightListHowToUse")),
                  content: Text(_t.translate("flightListHowToUseContent")),
                  actions: [TextButton(child: Text(_t.translate("OK")), onPressed: () => Navigator.of(context).pop())],
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 720;
          return isTablet ? _buildTabletLayout() : _buildPhoneLayout();
        },
      ),
    );
  }
}