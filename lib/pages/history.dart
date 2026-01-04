import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technical_test_flutter_stefanini/models/clock_in_type.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class ClockInEntry {
  final DateTime dateTime;
  final ClockInType type;

  ClockInEntry(this.dateTime, this.type);
}

class HistoryPageState extends State<HistoryPage> {
  List<ClockInEntry> _clockIns = [];

  @override
  void initState() {
    super.initState();
    _loadClockIns();
  }

  String _getTypeLabel(ClockInType type) {
    return type.label;
  }

  MaterialColor _getTypeColor(ClockInType type) {
    switch (type) {
      case ClockInType.shiftStart:
        return Colors.green;
      case ClockInType.lunchStart:
        return Colors.orange;
      case ClockInType.lunchEnd:
        return Colors.orange;
      case ClockInType.shiftEnd:
        return Colors.red;
      case ClockInType.additional:
        return Colors.grey;
    }
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

    final List<ClockInEntry> classified = [];
    for (final entry in history) {
      try {
        final parts = entry.split('|');
        final dt = DateTime.parse(parts[0]);
        final classificationIndex = int.parse(parts[1]);
        classified.add(ClockInEntry(dt, _getClockInTypeFromIndex(classificationIndex)));
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    classified.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    setState(() {
      _clockIns = classified;
    });
  }

  ClockInType _getClockInTypeFromIndex(int index) {
    return ClockInTypeExtension.fromIndex(index);
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "History",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                ),
                child: Text(
                  'CLEAR',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
        Expanded(
          child: _clockIns.isEmpty
              ? Center(
                  child: Text(
                    'No entries',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _clockIns.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 24,
                    endIndent: 24,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final entry = _clockIns[index];
                    final dt = entry.dateTime;
                    final type = entry.type;
                    final color = _getTypeColor(type);
                    final label = _getTypeLabel(type);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('HH:mm:ss').format(dt),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: color.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: color.shade700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(dt),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
