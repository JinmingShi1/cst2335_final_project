import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './pages/airplane_list_page.dart';
import 'localization/AppLocalizations.dart';

import './pages/reservation_page.dart';
import './dao/ReservationDao.dart';
import 'database/reservation_database.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initial reservation DAO
  final db = await $FloorReservationDatabase
      .databaseBuilder('app_database.db')
      .build();
  final dao = db.reservationDao;

  runApp(MyApp(dao: dao));
}


class MyApp extends StatefulWidget {

  final ReservationDao dao; //add ReservationDao

  const MyApp({super.key, required this.dao});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
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
        if (settings.name == '/airplanes') {
          return MaterialPageRoute(builder: (_) => const AirplaneListPage());
        }
        if (settings.name == '/reservation') {
          return MaterialPageRoute(builder: (_) => ReservationPage(dao: widget.dao));
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
                newLocale = const Locale('fr'); // Changed to French
              }
              MyApp.setLocale(context, newLocale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text("English (US)")),
              PopupMenuItem(value: 'fr', child: Text("Français (French)")), // Changed to French
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
                Navigator.pushNamed(context, '/airplanes');
              },
              child: Text(t.translate("airplaneListTitle") ?? ''),
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