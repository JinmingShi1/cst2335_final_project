import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'database/reservationDatabase.dart';
import 'dao/reservationDao.dart';
import 'entities/Reservation.dart';

late ReservationDao myDAO;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorReservationDatabase
      .databaseBuilder('app_database.db')
      .build();
  myDAO = database.reservationDao;

  runApp(const ReservationPage());
}

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ReservationListPage (title: 'Reservation'),
    );
  }
}

class Flight {
  final String flightNumber;
  final String departureCity;
  final String arrivalCity;

  Flight({required this.flightNumber, required this.departureCity, required this.arrivalCity});
}

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key, required this.title});

  final String title;

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  List<Reservation> reservations = [];
  final TextEditingController customerController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  Reservation? selectedItem;

  final EncryptedSharedPreferences encryptedSharedPreferences = EncryptedSharedPreferences();

  Flight? selectedFlight;

  final List<Flight> availableFlights = [
    Flight(flightNumber: 'AC101',
        departureCity: 'Toronto',
        arrivalCity: 'Vancouver'),
    Flight(flightNumber: 'AC202',
        departureCity: 'Montreal',
        arrivalCity: 'Calgary'),
  ];

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _loadSavedInputs();
    selectedFlight = availableFlights.first;
  }

  void _loadReservations() async {
    final dbItems = await myDAO.getAllReservations();
    setState(() {
      reservations = dbItems;
    });
  }

  void _loadSavedInputs() async {
    customerController.text =
        await encryptedSharedPreferences.getString('customer') ?? '';
    dateController.text =
        await encryptedSharedPreferences.getString('date') ?? '';
    commentController.text =
        await encryptedSharedPreferences.getString('comment') ?? '';
  }

  void _saveReservation() async {
    await encryptedSharedPreferences.setString(
        'customer', customerController.text);
    await encryptedSharedPreferences.setString('date', dateController.text);
    await encryptedSharedPreferences.setString(
        'comment', commentController.text);

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

    final newReservation = Reservation(
      id: null,
      customer: customer,
      flight: flight,
      date: date,
      comment: comment,
    );


    await myDAO.insertReservation(newReservation);

    setState(() {
      customerController.clear();
      dateController.clear();
      commentController.clear();
      selectedFlight = null;
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation added')),
    );

    _cancelReservation();
  }

  void _deleteReservation(Reservation res) async {
    await myDAO.deleteReservation(res);
    _loadReservations();
    setState(() {
      selectedItem = null;
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('How to Use'),
            content: const Text(
                'This page lists all your reservations. Tap + to add a new one. Tap an item to view details.'),
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

  Widget _buildListView() {
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final res = reservations[index];
        return ListTile(
          title: Text('${res.customer} - ${res.flight} - ${res.date}'),
          subtitle: Text(res.comment),
          onTap: () {
            setState(() {
              selectedItem = res;
            });
          },
          onLongPress: () async {
            await myDAO.deleteReservation(res); // 从数据库删除
            _loadReservations(); // 重新加载列表
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted: ${res.customer} - ${res.flight}'),
                backgroundColor: Colors.redAccent,),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsView(Reservation res) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer: ${res.customer}', style: TextStyle(fontSize: 20)),
          Text('Flight: ${res.flight}'),
          Text('Date: ${res.date}'),
          Text('Comment: ${res.comment}'),

          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _deleteReservation(res),
                child: const Text('Delete'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedItem = null;
                  });
                },
                child: const Text('Close'),
              ),
            ],
          )
        ],
      ),
    );
  }


  Widget reactiveLayout(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;

    if (width > 720) {
      return Row(
        children: [
          Expanded(child: _buildListView()),
          Expanded(
            child: selectedItem != null
                ? _buildDetailsView(selectedItem!)
                : const Center(child: Text("Select an item")),
          ),
        ],
      );
    } else {
      return selectedItem == null
          ? _buildListView()
          : _buildDetailsView(selectedItem!);
    }
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
            Text('Total Reservations: ${reservations.length}',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium),
            const SizedBox(height: 20),

            SizedBox(
              width: 400,
              child: TextField(controller: customerController,
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
                    child: Text('${flight.flightNumber} - ${flight
                        .departureCity} → ${flight.arrivalCity}'),
                  );
                }).toList(),
                onChanged: (Flight? value) {
                  setState(() {
                    selectedFlight = value;
                  });
                },
              ),
            ),

            //Date Picker
            SizedBox(
              width: 400,
              child:
              TextField(controller: dateController,
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
                    String formattedDate =
                        "${pickDate.year}-${_twoDigits(
                        pickDate.month)}-${_twoDigits(pickDate.day)}";
                    setState(() {
                      dateController.text = formattedDate;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            //comment TextArea + Buttons
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Add a comment',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,),
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
                          child: const Text('cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

      const SizedBox(height: 20),
      const Text('Your Reservations:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),

      //Reservation List
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
