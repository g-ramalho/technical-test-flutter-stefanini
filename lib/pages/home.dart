import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
