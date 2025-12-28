import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:technical_test_flutter_stefanini/system_datetime.dart';

void main() {
 runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ShiftTracker",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ClockInPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shift Tracker")),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => _onItemTapped(1),
        child: const Icon(Icons.assignment_ind),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: _selectedIndex == 2 ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  Future<SystemDateTime>? _futureSystemDateTime;

  Future<void> _handleClockIn() async {
    final bool? shouldClockIn = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clock In'),
        content: const Text('Are you sure you want to clock in?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldClockIn == true) {
      setState(() {
        _futureSystemDateTime = fetchDateTime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        FutureBuilder<SystemDateTime>(
          future: _futureSystemDateTime,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final dt = snapshot.data!.asDateTime();
              return Text(
                DateFormat('HH:mm:ss').format(dt),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return const SizedBox(height: 64);
          },
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton(
                onPressed: _handleClockIn,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                ),
                child: const Text(
                  'Clock In',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Page'),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Page'),
    );
  }
}
