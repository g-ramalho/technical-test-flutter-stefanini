import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technical_test_flutter_stefanini/models/clock_in_type.dart';
import 'package:technical_test_flutter_stefanini/models/shift_reminder.dart';
import 'package:technical_test_flutter_stefanini/services/notification_service.dart';

class ShiftReminderPage extends StatefulWidget {
  const ShiftReminderPage({super.key});

  @override
  State<ShiftReminderPage> createState() => _ShiftReminderPageState();
}

class _ShiftReminderPageState extends State<ShiftReminderPage> {
  bool _remindersEnabled = false;
  List<ShiftReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? false;
      final remindersJson = prefs.getString('shift_reminders');
      if (remindersJson != null) {
        final List<dynamic> decoded = jsonDecode(remindersJson);
        _reminders = decoded
            .map((e) => ShiftReminder.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
  }

  Future<void> _updateRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', value);
    setState(() {
      _remindersEnabled = value;
    });
    await NotificationService().scheduleReminders();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_reminders.map((e) => e.toJson()).toList());
    await prefs.setString('shift_reminders', encoded);
    await NotificationService().scheduleReminders();
  }

  Future<void> _addReminder() async {
    final result = await showDialog<ShiftReminder>(
      context: context,
      builder: (context) => const _ReminderDialog(),
    );

    if (result != null) {
      setState(() {
        _reminders.add(result);
      });
      await _saveReminders();
    }
  }

  Future<void> _editReminder(int index) async {
    final result = await showDialog<ShiftReminder>(
      context: context,
      builder: (context) => _ReminderDialog(reminder: _reminders[index]),
    );

    if (result != null) {
      setState(() {
        _reminders[index] = result;
      });
      await _saveReminders();
    }
  }

  Future<void> _deleteReminder(int index) async {
    setState(() {
      _reminders.removeAt(index);
    });
    await _saveReminders();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shift Reminders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[300]),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SwitchListTile(
              title: Text(
                'Enable shift reminders',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
              subtitle: Text(
                'Receive notifications before clock-ins',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              value: _remindersEnabled,
              onChanged: _updateRemindersEnabled,
              activeThumbColor: Colors.black87,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
            ),
          ),
          if (_remindersEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REMINDERS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addReminder,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('ADD'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            if (_reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No reminders configured',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_reminders.length, (index) {
                final reminder = _reminders[index];
                final color = _getTypeColor(reminder.type);
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          reminder.type.label,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.shade50,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: color.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            reminder.scheduledTime.format(context),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: color.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Notify ${reminder.minutesBefore} min before',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                          onPressed: () => _editReminder(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: Colors.red[400]),
                          onPressed: () => _deleteReminder(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  final ShiftReminder? reminder;

  const _ReminderDialog({this.reminder});

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late ClockInType _selectedType;
  late TimeOfDay _selectedTime;
  late int _minutesBefore;

  final List<int> _minutesOptions = [5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.reminder?.type ?? ClockInType.shiftStart;
    _selectedTime = widget.reminder?.scheduledTime ?? const TimeOfDay(hour: 9, minute: 0);
    _minutesBefore = widget.reminder?.minutesBefore ?? 10;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clock-in Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ClockInType>(
            initialValue: _selectedType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              ClockInType.shiftStart,
              ClockInType.lunchStart,
              ClockInType.lunchEnd,
              ClockInType.shiftEnd,
            ].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Scheduled Time',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 15),
                  ),
                  Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Notify Before (minutes)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _minutesBefore,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: _minutesOptions.map((minutes) {
              return DropdownMenuItem(
                value: minutes,
                child: Text('$minutes minutes'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _minutesBefore = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              ShiftReminder(
                type: _selectedType,
                scheduledTime: _selectedTime,
                minutesBefore: _minutesBefore,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
