import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import '../dao/ReservationDao.dart';
import '../Entities/reservation_entity.dart';
import '../database/reservation_database.dart';


class ReservationPage extends StatelessWidget {
  final ReservationDao dao;

  const ReservationPage({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ReservationListPage(title: 'Reservation', dao: dao),
    );
  }
}

class Flight {
  final String flightNumber;
  final String departureCity;
  final String arrivalCity;

  Flight({
    required this.flightNumber,
    required this.departureCity,
    required this.arrivalCity,
  });
}

class ReservationListPage extends StatefulWidget {

  final String title;
  final ReservationDao dao;

  const  ReservationListPage({
    super.key,
    required this.title,
    required this.dao,
  });

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  late ReservationDao dao;
  List<Reservation> reservations = [];

  final customerController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();


  Flight? selectedFlight;
  final List<Flight> availableFlights = [
    Flight(flightNumber: 'AC101', departureCity: 'Toronto', arrivalCity: 'Vancouver'),
    Flight(flightNumber: 'AC202', departureCity: 'Montreal', arrivalCity: 'Calgary'),
  ];

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    dao = widget.dao;
    _loadReservations();
    _loadSavedInputs();
    selectedFlight = availableFlights.first;
  }

  void _loadReservations() async {
    final items = await dao.getAllReservations();
    setState(() {
      reservations = items;
    });
  }

  void _loadSavedInputs() async {
    customerController.text = await _prefs.getString('customer') ?? '';
    dateController.text = await _prefs.getString('date') ?? '';
    commentController.text = await _prefs.getString('comment') ?? '';
  }

  void _saveReservation() async {
    await _prefs.setString('customer', customerController.text);
    await _prefs.setString('date', dateController.text);
    await _prefs.setString('comment', commentController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation added')),
    );
  }

  void _cancelReservation() {
    customerController.clear();
    dateController.clear();
    commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inputs cleared')),
    );
  }

  void _addReservation() async {
    final customer = customerController.text.trim();
    final flight = selectedFlight?.flightNumber ?? '';
    final date = dateController.text.trim();
    final comment = commentController.text.trim();

    if (customer.isEmpty || flight.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final newRes = Reservation(
      id: null,
      customer: customer,
      flight: flight,
      date: date,
      comment: comment,
    );

    await dao.insertReservation(newRes);
    _loadReservations();

    setState(() {
      customerController.clear();
      dateController.clear();
      commentController.clear();
      selectedFlight = availableFlights.first;;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reservation added: $customer - $flight on $date')),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const Text(
            'This page lets you add and view flight reservations.\n'
                'Fill in the fields, then tap "+" or "Add your trip".\n'
                'Tap an item to view details, or long press to delete.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goBackToHome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent.shade100,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _goBackToHome,
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Reservations: ${reservations.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: 400,
              child: TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer'),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: 400,
              child: DropdownButton<Flight>(
                isExpanded: true,
                value: selectedFlight,
                items: availableFlights.map((flight) {
                  return DropdownMenuItem(
                    value: flight,
                    child: Text(
                        '${flight.flightNumber} - ${flight.departureCity} → ${flight.arrivalCity}'),
                  );
                }).toList(),
                onChanged: (Flight? value) {
                  setState(() {
                    selectedFlight = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: 400,
              child: TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2060),
                  );
                  if (pickDate != null) {
                    String formatted =
                        "${pickDate.year}-${_twoDigits(pickDate.month)}-${_twoDigits(pickDate.day)}";
                    setState(() {
                      dateController.text = formatted;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Add a comment',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 5,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveReservation,
                          child: const Text('Add your trip'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancelReservation,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Your Reservations:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final r = reservations[index];
                  return Text(
                    '${index + 1}: ${r.customer} - ${r.flight} - ${r.date}',
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReservation,
        tooltip: 'Add Reservation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
