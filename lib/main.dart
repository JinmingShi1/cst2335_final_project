import 'package:flutter/material.dart';

void main() {
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

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key, required this.title});

  final String title;

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final List<String> reservations = [];
  final TextEditingController customerController = TextEditingController();
  final TextEditingController flightController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController commentController = TextEditingController();



  void _addReservation() {
    final customer = customerController.text.trim();
    final flight = flightController.text.trim();
    final date = dateController.text.trim();
    final comment = commentController.text.trim();

    if (customer.isEmpty || flight.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final reservation = '$customer - $flight - $date - $comment';

    setState(() {
      reservations.add(reservation);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation added')),
    );

    _cancelReservation();
  }
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
  void _goBackToHome(){
    Navigator.pop(context);
  }

  void _saveReservation() {
    // You can implement the save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation saved')),
    );
  }

  void _cancelReservation() {
    customerController.clear();
    flightController.clear();
    dateController.clear();
    commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inputs cleared')),
    );
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
                              style: Theme.of(context).textTheme.titleMedium),
                       const SizedBox(height: 20),
            TextField(controller: customerController, decoration: const InputDecoration(labelText: 'Customer'),
    ),
            TextField(controller: flightController, decoration: const InputDecoration(labelText: 'Flight'),
    ),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date'),
    ),
            TextField(controller: commentController, decoration: const InputDecoration(labelText: 'Add a comment'),
    ),
                const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      ElevatedButton(
                      onPressed: _saveReservation,
                      child: const Text('Save'),
                    ),
                ElevatedButton(
                      onPressed: _cancelReservation,
                      child: const Text('Cancel'),
                    ),
            ],
    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    Expanded(
                      child:
                    ListView.builder(
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                      return ListTile(
                            title: Text(reservations[index]),
                            onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped: ${reservations[index]}')),
                    );
                  },
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
