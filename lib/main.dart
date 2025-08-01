import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './pages/airplane_list_page.dart';
import 'localization/AppLocalizations.dart';

import './pages/reservation_page.dart';
import './dao/reservation_dao.dart';
import './database/reservation_database.dart';

import './pages/customer_list_page.dart';
import './pages/flight_list_page.dart';

/// The main entry point for the application.
///
/// Initializes the database and runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initial reservation DAO
  final db = await $FloorReservationDatabase
      .databaseBuilder('app_database.db')
      .build();
  final dao = db.reservationDao;

  runApp(MyApp(dao: dao));
}

/// The root widget of the application.
///
/// This widget is stateful to allow for dynamic locale changes.
class MyApp extends StatefulWidget {
  /// The Data Access Object for reservations.
  final ReservationDao dao; //add ReservationDao

  const MyApp({super.key, required this.dao});

  /// Allows any widget in the tree to change the application's locale.
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

/// The state for [MyApp], managing the application's current locale.
class _MyAppState extends State<MyApp> {
  /// The currently active locale for the application.
  Locale _locale = const Locale('en');

  /// Updates the application's locale and rebuilds the UI.
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
              builder: (_) => FlightListPage());
        }

        if (settings.name == '/reservation') {
          return MaterialPageRoute(builder: (_) => ReservationPage(dao: widget.dao));
        }
        return null;
      },
    );
  }
}

/// The home page of the application, displaying the main menu.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('title') ?? 'Project'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (lang) {
              final newLocale = Locale(lang);
              MyApp.setLocale(context, newLocale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text("English (US)")),
              PopupMenuItem(value: 'fr', child: Text("Français (French)")),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // A more prominent welcome text
            Text(
              t.translate('helpText') ?? 'Select a feature to begin.',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // The GridView takes up the remaining space
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context: context,
                    icon: Icons.people_alt_outlined,
                    title: t.translate("customerListTitle") ?? 'Customers',
                    routeName: '/customers',
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.airplanemode_active,
                    title: t.translate("airplaneListTitle") ?? 'Airplanes',
                    routeName: '/airplanes',
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.flight_takeoff,
                    title: t.translate("flightListTitle") ?? 'Flights',
                    routeName: '/flightList',
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.book_online,
                    title: t.translate("reservationTitle") ?? 'Reservations',
                    routeName: '/reservation',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to build the styled menu cards, avoiding code repetition.
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}