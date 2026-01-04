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

  Future<void> _resetPreferences() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'This will reset all settings to defaults and clear all clock-in history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All settings have been reset to defaults'),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Text(
            'AUTO CLEAR',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Enable automatic clearance',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  'Clear history daily at set time',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                value: _autoClearEnabled,
                onChanged: _updateAutoClearEnabled,
                activeThumbColor: Colors.black87,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              ListTile(
                title: Text(
                  'Clearance time',
                  style: TextStyle(
                    fontSize: 15,
                    color: _autoClearEnabled ? Colors.grey[800] : Colors.grey[400],
                  ),
                ),
                subtitle: Text(
                  _autoClearTime.format(context),
                  style: TextStyle(
                    fontSize: 13,
                    color: _autoClearEnabled ? Colors.grey[500] : Colors.grey[300],
                  ),
                ),
                enabled: _autoClearEnabled,
                trailing: Icon(
                  Icons.access_time,
                  size: 20,
                  color: _autoClearEnabled ? Colors.grey[600] : Colors.grey[300],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Text(
            'DANGER ZONE',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: Colors.red[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            title: Text(
              'Reset all settings',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red[700],
              ),
            ),
            subtitle: Text(
              'Clear all data and return to defaults',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[400],
              ),
            ),
            trailing: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Colors.red[600],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            onTap: _resetPreferences,
          ),
        ),
      ],
    );
  }
}