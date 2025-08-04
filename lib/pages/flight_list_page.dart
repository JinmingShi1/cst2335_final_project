import 'package:flutter/material.dart';
import '../Entities/flight_entity.dart';
import '../dao/flight_dao.dart';
import 'flight_detail_page.dart';


class FlightListPage extends StatefulWidget {
  final FlightDao dao;

  const FlightListPage({super.key, required this.dao});

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  late Future<List<Flight>> flightsFuture;

  @override
  void initState() {
    super.initState();
    flightsFuture = widget.dao.findAllFlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flight List"),
      ),
      body: FutureBuilder<List<Flight>>(
        future: flightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final flights = snapshot.data ?? [];

          if (flights.isEmpty) {
            return const Center(child: Text("No flights available."));
          }

          return ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
              return ListTile(
                title: Text('${flight.departureCity} → ${flight.destinationCity}'),
                subtitle: Text('Depart: ${flight.departureTime} - Arrive: ${flight.arrivalTime}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/flightDetail',
                    arguments: {'flight': flight, 'dao': widget.dao},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
