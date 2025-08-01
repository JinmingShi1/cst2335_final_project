import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../dao/ReservationDao.dart';
import '../Entities/reservation_entity.dart';
import '../localization/AppLocalizations.dart';
import 'package:cst2335_final_project/main.dart';
import '../Entities/flight_entity.dart';
import '../database/reservation_database.dart';

void showHelpDialog(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.translate('helpTitle')),
      content: Text(t.translate('helpText')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.translate('ok')),
        ),
      ],
    ),
  );
}

class ReservationPage extends StatelessWidget {
  final ReservationDao dao;
  const ReservationPage({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    return ReservationListPage(
      title: AppLocalizations.of(context)!.translate('reservationTitle'),
      dao: dao,
    );
  }
}

class ReservationListPage extends StatefulWidget {
  final String title;
  final ReservationDao dao;
  const ReservationListPage({
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
  List<Flight> availableFlights = [];

  final customerController = TextEditingController();
  final dateController = TextEditingController();
  final commentController = TextEditingController();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  Flight? selectedFlight;
  Reservation? selectedReservation;

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    dao = widget.dao;
    _loadReservations();
    _loadSavedInputs();
    _loadFlights(); // ⬅ 加载数据库中的航班
  }

  void _loadFlights() async {
    final db = await $FloorReservationDatabase
        .databaseBuilder('app_database.db')
        .build();
    final flights = await db.flightDao.findAllFlights();
    setState(() {
      availableFlights = flights;
      selectedFlight = flights.isNotEmpty ? flights.first : null;
    });
  }

  void _loadReservations() async {
    final items = await dao.getAllReservations();
    setState(() {
      reservations = items;
      if (selectedReservation != null &&
          !reservations.any((r) => r.id == selectedReservation!.id)) {
        selectedReservation = null;
      }
    });
  }

  void _loadSavedInputs() async {
    customerController.text = await _prefs.getString('customer') ?? '';
    dateController.text = await _prefs.getString('date') ?? '';
    commentController.text = await _prefs.getString('comment') ?? '';
  }

  void _cancelReservation() {
    customerController.clear();
    dateController.clear();
    commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.translate('inputsCleared'))),
    );
  }

  void _addReservation() async {
    final t = AppLocalizations.of(context)!;
    final customer = customerController.text.trim();
    final flight = selectedFlight != null
        ? '${selectedFlight!.departureCity} → ${selectedFlight!.destinationCity}'
        : '';
    final date = dateController.text.trim();
    final comment = commentController.text.trim();

    if (customer.isEmpty || flight.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('pleaseFillFields'))),
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
      selectedFlight = availableFlights.isNotEmpty ? availableFlights.first : null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.translate('added'))),
    );
  }

  void _goBackToHome() {
    Navigator.pop(context);
  }

  void _deleteSelectedReservation() async {
    if (selectedReservation != null) {
      await dao.deleteReservation(selectedReservation!);
      setState(() {
        reservations.removeWhere((r) => r.id == selectedReservation!.id);
        selectedReservation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    var size = MediaQuery.of(context).size;

    if (size.width > size.height && size.width > 720.0) {
      return Scaffold(
        appBar: _buildAppBar(t),
        body: Row(
          children: [
            Expanded(flex: 1, child: _listViewPage(t)),
            Container(width: 2, color: Colors.deepPurpleAccent.shade100.withOpacity(0.5)),
            Expanded(
              flex: 2,
              child: selectedReservation != null
                  ? _detailsPage(context, t)
                  : Center(child: Text(t.translate('selectReservation'))),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: _buildAppBar(t),
        body: selectedReservation == null
            ? _listViewPage(t)
            : _detailsPage(context, t),
      );
    }
  }

  AppBar _buildAppBar(AppLocalizations t) {
    return AppBar(
      backgroundColor: Colors.deepPurpleAccent.shade100,
      leading: IconButton(
        icon: const Icon(Icons.home),
        onPressed: _goBackToHome,
      ),
      title: Text(widget.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => showHelpDialog(context),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (value) {
            Locale newLocale = (value == 'en') ? const Locale('en') : const Locale('fr');
            MyApp.setLocale(context, newLocale);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'en', child: Text('English (US)')),
            PopupMenuItem(value: 'fr', child: Text('Français (French)')),
          ],
        ),
      ],
    );
  }

  Widget _listViewPage(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(t.translate('customer')!, customerController),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: Text(t.translate('chooseFlight'), style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 400,
              child: DropdownButton<Flight>(
                isExpanded: true,
                value: selectedFlight,
                items: availableFlights.map((flight) {
                  return DropdownMenuItem(
                    value: flight,
                    child: Text('${flight.departureCity} → ${flight.destinationCity} (${flight.departureTime})'),
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
            _buildDatePicker(t),
            const SizedBox(height: 20),
            _buildCommentBox(t),
            const SizedBox(height: 20),
            _buildButtons(t),
            const SizedBox(height: 20),
            Text(t.translate('yourReservations'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final r = reservations[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedReservation = r;
                      });
                    },
                    child: Text('${index + 1}: ${r.customer} - ${r.flight} - ${r.date}', style: const TextStyle(fontSize: 14)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildDatePicker(AppLocalizations t) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: dateController,
        decoration: InputDecoration(labelText: t.translate('date')),
        readOnly: true,
        onTap: () async {
          DateTime? pickDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2022),
            lastDate: DateTime(2060),
          );
          if (pickDate != null) {
            String formatted = "${pickDate.year}-${_twoDigits(pickDate.month)}-${_twoDigits(pickDate.day)}";
            setState(() {
              dateController.text = formatted;
            });
          }
        },
      ),
    );
  }

  Widget _buildCommentBox(AppLocalizations t) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: commentController,
        decoration: InputDecoration(
          labelText: t.translate('comment'),
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: 5,
      ),
    );
  }

  Widget _buildButtons(AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _addReservation,
            child: Text(t.translate('addReservation')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _cancelReservation,
            child: Text(t.translate('cancel')),
          ),
        ),
      ],
    );
  }

  Widget _detailsPage(BuildContext context, AppLocalizations t) {
    if (selectedReservation == null) {
      return Center(child: Text(t.translate('Check your Reservation'), style: const TextStyle(fontSize: 20)));
    }
    final r = selectedReservation!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 2,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${t.translate('customer')}: ${r.customer}", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text("${t.translate('flight')}: ${r.flight}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("${t.translate('date')}: ${r.date}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              if ((r.comment ?? '').isNotEmpty) Text(r.comment!, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedReservation = null;
                      });
                    },
                    child: Text(t.translate('ok')),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () async {
                      await dao.deleteReservation(r);
                      setState(() {
                        reservations.removeWhere((rr) => rr.id == r.id);
                        selectedReservation = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.translate('deleted'))),
                      );
                    },
                    child: Text(t.translate('delete')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
