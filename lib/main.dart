import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './pages/airplane_list_page.dart';
import 'localization/AppLocalizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        Locale('zh', 'CN'),
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
      routes: {
        // '/': (context) => const MyHomePage(),
        '/airplanes': (context) => const AirplaneListPage(),
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
                newLocale = const Locale('zh', 'cn');
              }
              MyApp.setLocale(context, newLocale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text("English (US)")),
              PopupMenuItem(value: 'zh', child: Text("中文 (简体)")),
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
              child: Text(t.translate("addAirplane") ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}