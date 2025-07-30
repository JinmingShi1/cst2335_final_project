import 'package:cst2335_final_project/pages/customer_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

 Zama_Emmerencia1


void main() {
  runApp(const MyApp(

  ));
}

import './pages/airplane_list_page.dart';
import 'localization/AppLocalizations.dart';
 main

import './pages/reservation_page.dart';
import './dao/ReservationDao.dart';
import 'database/reservation_database.dart';

 Zama_Emmerencia1
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CustomerListPage(),
    );
  }


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initial reservation DAO
  final db = await $FloorReservationDatabase
      .databaseBuilder('app_database.db')
      .build();
  final dao = db.reservationDao;

  runApp(MyApp(dao: dao));
 main
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