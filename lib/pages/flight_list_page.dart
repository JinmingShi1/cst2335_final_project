import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/flight_dao.dart';
import '../database/flight_database.dart';
import '../Entities/flight_entity.dart';
import '../localization/AppLocalizations.dart';
import 'flight_detail_page.dart';

/// A page that displays a list of flights and allows for adding new ones.
class FlightListPage extends StatefulWidget {
  const FlightListPage({super.key});

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

/// State for the [FlightListPage].
class _FlightListPageState extends State<FlightListPage> {
  late AppLocalizations t;
  late FlightDao dao;
  /// A future that holds the list of flights, used by the [FutureBuilder].
  late Future<List<Flight>> flightsFuture;
  bool isDbInitialized = false;

  /// The currently selected flight in the tablet layout.
  Flight? _selectedFlightForTablet;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    t = AppLocalizations.of(context)!;
  }

  /// Initializes the database connection and loads the initial list of flights.
  Future<void> _initializeDatabase() async {
    final db = await $FloorFlightDatabase.databaseBuilder('flights.db').build();
    dao = db.flightDao;
    setState(() {
      isDbInitialized = true;
      _loadFlights();
    });
    _promptForSavedData();
  }

  /// Refreshes the list of flights from the database.
  void _loadFlights() {
    if (!isDbInitialized) return;
    setState(() {
      flightsFuture = dao.findAllFlights();
    });
  }

  /// Asks the user if they want to reuse the last entered data.
  Future<void> _promptForSavedData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final useLast = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.translate("flightListUsePreviousData")),
          content: Text(t.translate("flightListReuseLastInput")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.translate("No"))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.translate("Yes"))),
          ],
        ),
      );
      if (useLast == true) {
        _showAddFlightDialog(loadPrevious: true);
      }
    });
  }

  /// Shows a dialog for adding a new flight.
  void _showAddFlightDialog({bool loadPrevious = false}) {
    final formKey = GlobalKey<FormState>();
    final departureCityCtrl = TextEditingController();
    final destinationCityCtrl = TextEditingController();
    final departureTimeCtrl = TextEditingController();
    final arrivalTimeCtrl = TextEditingController();

    if (loadPrevious) {
      _storage.read(key: 'flight_last_dep_city').then((v) => departureCityCtrl.text = v ?? '');
      _storage.read(key: 'flight_last_dest_city').then((v) => destinationCityCtrl.text = v ?? '');
      _storage.read(key: 'flight_last_dep_time').then((v) => departureTimeCtrl.text = v ?? '');
      _storage.read(key: 'flight_last_arr_time').then((v) => arrivalTimeCtrl.text = v ?? '');
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate("flightListAddFlight")),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: departureCityCtrl, decoration: InputDecoration(labelText: t.translate("flightListDepartureCity")), validator: (v) => v!.isEmpty ? "Required" : null),
                  TextFormField(controller: destinationCityCtrl, decoration: InputDecoration(labelText: t.translate("flightListDestinationCity")), validator: (v) => v!.isEmpty ? "Required" : null),
                  TextFormField(controller: departureTimeCtrl, decoration: InputDecoration(labelText: t.translate("flightListDepartureTime")), validator: (v) => v!.isEmpty ? "Required" : null),
                  TextFormField(controller: arrivalTimeCtrl, decoration: InputDecoration(labelText: t.translate("flightListArrivalTime")), validator: (v) => v!.isEmpty ? "Required" : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(t.translate("Cancel"))),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newFlight = Flight(
                  departureCity: departureCityCtrl.text,
                  destinationCity: destinationCityCtrl.text,
                  departureTime: departureTimeCtrl.text,
                  arrivalTime: arrivalTimeCtrl.text,
                );
                await dao.insertFlight(newFlight);

                await _storage.write(key: 'flight_last_dep_city', value: departureCityCtrl.text);
                await _storage.write(key: 'flight_last_dest_city', value: destinationCityCtrl.text);
                await _storage.write(key: 'flight_last_dep_time', value: departureTimeCtrl.text);
                await _storage.write(key: 'flight_last_arr_time', value: arrivalTimeCtrl.text);

                Navigator.pop(context);
                _loadFlights();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.translate("flightListFlightAdded"))));
              },
              child: Text(t.translate("Add")),
            )
          ],
        );
      },
    );
  }

  /// Navigates to the detail page for a given flight.
  void _navigateToDetail(Flight flight) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlightDetailPage(flight: flight, dao: dao)),
    );
    if (result == true) {
      _loadFlights();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("flightListTitle")),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t.translate("flightListHowToUse")),
                content: Text(t.translate("flightListHowToUseContent")),
                actions: [TextButton(child: Text(t.translate("OK")), onPressed: () => Navigator.of(context).pop())],
              ),
            ),
          ),
        ],
      ),
      body: !isDbInitialized
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return _buildTabletLayout();
        } else {
          return _buildPhoneLayout();
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFlightDialog(),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the main body of the page, shared by phone and tablet layouts.
  Widget _buildSharedBody() {
    return FutureBuilder<List<Flight>>(
      future: flightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(t.translate("flightListNoFlights")));
        }
        final flights = snapshot.data!;
        return ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) {
            final flight = flights[index];
            return _buildFlightListItem(
              flight: flight,
              onTap: () {
                if (MediaQuery.of(context).size.width > 700) {
                  setState(() => _selectedFlightForTablet = flight);
                } else {
                  _navigateToDetail(flight);
                }
              },
            );
          },
        );
      },
    );
  }

  /// Builds the UI for phone screens.
  Widget _buildPhoneLayout() {
    return _buildSharedBody();
  }

  /// Builds the UI for tablet screens.
  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(width: 400, child: _buildSharedBody()),
        const VerticalDivider(),
        Expanded(
          child: _selectedFlightForTablet == null
              ? Center(child: Text(t.translate("flightListSelectToSeeDetails")))
              : FlightDetailPage(
            key: ValueKey(_selectedFlightForTablet!.id),
            flight: _selectedFlightForTablet!,
            dao: dao,
          ),
        ),
      ],
    );
  }

  /// Builds a single card widget representing a flight in the list.
  Widget _buildFlightListItem({required Flight flight, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.deepOrange, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${flight.departureCity} → ${flight.destinationCity}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${t.translate("flightListDepartureTime")}: ${flight.departureTime} | ${t.translate("flightListArrivalTime")}: ${flight.arrivalTime}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}