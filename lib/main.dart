import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/constants/all.dart';
import 'data/models/all.dart';
import 'utils/all.dart';

ApplicationInsightsImp? appInsightsImp;
Future<void> main() async {
  await dotenv.load();
  final key = dotenv.env[appInsightsKey];

  appInsightsImp = ApplicationInsightsImp(key!);

  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    runWithCrashReporting(codeToExecute: run);
  } else {
    run();
  }
}

void run() => runApp(const MyApp());

Future<void> runWithCrashReporting({
  required VoidCallback codeToExecute,
}) async {
  FlutterError.onError = (error) => appInsightsImp?.trackError(
      isFatal: true, error: error.exception, stackTrace: error.stack);

  runZonedGuarded(
    codeToExecute,
    (error, stackTrace) => appInsightsImp?.trackError(
      isFatal: true,
      error: error,
      stackTrace: stackTrace,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({key, appInsightsHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  String _selectedLabel = home;

  final List<MyTabItem> _tabItems = [
    MyTabItem(
        index: 0,
        label: home,
        icon: const Icon(Icons.home),
        backgroundColor: Colors.red),
    MyTabItem(
        index: 1,
        label: business,
        icon: const Icon(Icons.business),
        backgroundColor: Colors.green),
    MyTabItem(
        index: 2,
        label: school,
        icon: const Icon(Icons.school),
        backgroundColor: Colors.blue),
    MyTabItem(
      index: 3,
      label: settings,
      icon: const Icon(Icons.settings),
      backgroundColor: Colors.grey,
    ),
    MyTabItem(
      index: 3,
      label: camera,
      icon: const Icon(Icons.camera),
      backgroundColor: Colors.black,
    ),
  ];

  List<BottomNavigationBarItem> getBottomTabs(List<MyTabItem> tabs) {
    return tabs
        .map((tab) => BottomNavigationBarItem(
            icon: tab.icon!,
            label: tab.label,
            backgroundColor: tab.backgroundColor))
        .toList();
  }

  void _onItemTapped(int index) async {
    final String label = _tabItems[index].label.toString();
    final String trackEventTrace =
        "User tapped at $label bottom navigation bar";
    // Track screens from the BottomNavigationBar
    appInsightsImp?.trackPageView(name: label);
    // Track event from the BottomNavigationBar
    appInsightsImp?.trackEvent(name: trackEventTrace);
    // Track trace from the BottomNavigationBar
    appInsightsImp?.trackTrace(message: trackEventTrace);

    setState(() {
      _selectedIndex = index;
      _selectedLabel = label;
    });
  }

  @override
  void initState() {
    super.initState();
    // Track http when init application
    appInsightsImp?.trackTraceHttp('https://api.github.com/users/carlosgsrosa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Insights Example'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedLabel,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                throw Exception("Error ${DateTime.now()} $_selectedLabel");
              },
              child: const Text('Throw error'),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: getBottomTabs(_tabItems),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
