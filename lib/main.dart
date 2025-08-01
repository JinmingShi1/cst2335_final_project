import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './pages/airplane_list_page.dart';
import 'localization/AppLocalizations.dart';

import './pages/reservation_page.dart';
import './dao/ReservationDao.dart';
import './dao/flight_dao.dart';
import './database/reservation_database.dart';

import './pages/customer_list_page.dart';
import './pages/flight_detail_page.dart';
import './pages/flight_list_page.dart';
import 'Entities/flight_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 ReservationDao 和 FlightDao，使用 ReservationDatabase 即可
  final db = await $FloorReservationDatabase
      .databaseBuilder('app_database.db')
      .build();
  final reservationDao = db.reservationDao;
  final flightDao = db.flightDao;

  final existingFlights = await flightDao.findAllFlights();
  if (existingFlights.isEmpty) {
    await flightDao.insertFlight(Flight(
      departureCity: 'Toronto',
      destinationCity: 'Vancouver',
      departureTime: '10:00',
      arrivalTime: '13:00',
    ));
    await flightDao.insertFlight(Flight(
      departureCity: 'Montreal',
      destinationCity: 'Calgary',
      departureTime: '09:30',
      arrivalTime: '12:45',
    ));
    print("✅ Default flights inserted.");
  }


  runApp(MyApp(
    reservationDao: reservationDao,
    flightDao: flightDao,
  ));
}

class MyApp extends StatefulWidget {
  final ReservationDao reservationDao;
  final FlightDao flightDao;

  const MyApp({
    super.key,
    required this.reservationDao,
    required this.flightDao,
  });

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyHomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/customers') {
          return MaterialPageRoute(builder: (_) => const CustomerListPage());
        }
        if (settings.name == '/airplanes') {
          return MaterialPageRoute(builder: (_) => const AirplaneListPage());
        }
        if (settings.name == '/flightList') {
          return MaterialPageRoute(
              builder: (_) => FlightListPage(dao: widget.flightDao));
        }
        if (settings.name == '/flightDetail') {
          final args = settings.arguments as Map<String, dynamic>;
          final flight = args['flight'] as Flight;
          final dao = args['dao'] as FlightDao;

          return MaterialPageRoute(
            builder: (_) => FlightDetailPage(flight: flight, dao: dao),
          );
        }
        if (settings.name == '/reservation') {
          return MaterialPageRoute(
              builder: (_) => ReservationPage(dao: widget.reservationDao));
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(t.translate('title') ?? ''),
        actions: [
          PopupMenuButton<String>(
            onSelected: (lang) {
              Locale newLocale;
              if (lang == 'en') {
                newLocale = const Locale('en');
              } else {
                newLocale = const Locale('fr');
              }
              MyApp.setLocale(context, newLocale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text("English (US)")),
              PopupMenuItem(value: 'fr', child: Text("Français (French)")),
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(t.translate('helpText') ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/customers');
              },
              child: Text(t.translate("customerListTitle") ?? ''),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/airplanes');
              },
              child: Text(t.translate("airplaneListTitle") ?? ''),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/flightList');
              },
              child: Text(t.translate("flightListTitle") ?? 'Flights Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reservation');
              },
              child: Text(t.translate("Reservation") ?? 'Reservation Page'),
            ),
          ],
        ),
      ),
    );
  }
}
