import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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