import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _selectedIndex = 1;
  final GlobalKey<_HomePageState> _homePageKey = GlobalKey();

  late final List<Widget> _pages = [
    HomePage(key: _homePageKey),
    ClockInPage(onClockInSuccess: _handleClockInSuccess),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _homePageKey.currentState?.refresh();
    }
  }

  void _handleClockInSuccess() {
    _homePageKey.currentState?.refresh();
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
  final VoidCallback? onClockInSuccess;
  const ClockInPage({super.key, this.onClockInSuccess});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  Future<SystemDateTime>? _futureSystemDateTime;
  bool _isConnected = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (mounted) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    }
  }

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

      _futureSystemDateTime?.then((dt) {
        _saveClockIn(dt.asDateTime());
        widget.onClockInSuccess?.call();
      }, onError: (error) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while clocking in. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  Future<void> _saveClockIn(DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('clock_in_history') ?? [];
    history.add(dt.toIso8601String());
    await prefs.setStringList('clock_in_history', history);
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
            } else if (snapshot.hasData) {
              final dt = snapshot.data!.asDateTime();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm:ss').format(dt),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'LAST RECEIVED DATETIME',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox(height: 64);
          },
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isConnected) ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'There must be an active connection to clock in',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: 200,
                  height: 200,
                  child: ElevatedButton(
                    onPressed: _isConnected ? _handleClockIn : null,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DateTime> _clockIns = [];

  @override
  void initState() {
    super.initState();
    _loadClockIns();
  }

  Future<void> refresh() async {
    await _loadClockIns();
  }

  Future<void> _checkAutoClear(SharedPreferences prefs) async {
    final bool autoClearEnabled = prefs.getBool('auto_clear_enabled') ?? false;
    if (autoClearEnabled) {
      final String? timeStr = prefs.getString('auto_clear_time');
      if (timeStr != null) {
        final parts = timeStr.split(':');
        final clearTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

        final now = DateTime.now();
        final lastClearStr = prefs.getString('last_auto_clear_date');
        final todayStr = DateFormat('yyyy-MM-dd').format(now);

        if (lastClearStr != todayStr) {
          if (now.hour > clearTime.hour ||
              (now.hour == clearTime.hour && now.minute >= clearTime.minute)) {
            await prefs.remove('clock_in_history');
            await prefs.setString('last_auto_clear_date', todayStr);
          }
        }
      }
    }
  }

  Future<void> _loadClockIns() async {
    final prefs = await SharedPreferences.getInstance();
    
    await _checkAutoClear(prefs);

    final List<String> history = prefs.getStringList('clock_in_history') ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _clockIns = history
          .map((e) => DateTime.parse(e))
          .where((dt) {
            final date = DateTime(dt.year, dt.month, dt.day);
            return date.isAtSameMomentAs(today);
          })
          .toList()
        ..sort((a, b) => a.compareTo(b));
    });
  }

  Future<void> _clearHistory() async {
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear History'),
        content: const Text('Are you sure you want to clear the clock-in history?'),
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

    if (shouldClear == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('clock_in_history');
      await _loadClockIns();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: _clearHistory,
              child: const Text('Clear History'),
            ),
          ),
        ),
        Expanded(
          child: _clockIns.isEmpty
              ? const Center(child: Text('No clock-ins for today'))
              : ListView.builder(
                  itemCount: _clockIns.length,
                  itemBuilder: (context, index) {
                    final dt = _clockIns[index];
                    return ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(DateFormat('HH:mm:ss').format(dt)),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(dt)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoClearEnabled = false;
  TimeOfDay _autoClearTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoClearEnabled = prefs.getBool('auto_clear_enabled') ?? false;
      final timeStr = prefs.getString('auto_clear_time');
      if (timeStr != null) {
        final parts = timeStr.split(':');
        _autoClearTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    });
  }

  Future<void> _updateAutoClearEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_clear_enabled', value);
    setState(() {
      _autoClearEnabled = value;
    });
  }

  Future<void> _updateAutoClearTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auto_clear_time', '${time.hour}:${time.minute}');
    setState(() {
      _autoClearTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Recurrent, automatic History Clearance'),
          subtitle: const Text('Clear history automatically at a specific time'),
          value: _autoClearEnabled,
          onChanged: _updateAutoClearEnabled,
        ),
        ListTile(
          title: const Text('Clearance Time'),
          subtitle: Text(_autoClearTime.format(context)),
          enabled: _autoClearEnabled,
          trailing: const Icon(Icons.access_time),
          onTap: _autoClearEnabled
              ? () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _autoClearTime,
                  );
                  if (picked != null && picked != _autoClearTime) {
                    _updateAutoClearTime(picked);
                  }
                }
              : null,
        ),
      ],
    );
  }
}
