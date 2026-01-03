import 'package:flutter/material.dart';

import 'clock_in.dart';
import 'history.dart';
import 'settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  final GlobalKey<HistoryPageState> _homePageKey = GlobalKey();

  late final List<Widget> _pages = [
    HistoryPage(key: _homePageKey),
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
      appBar: AppBar(
        title: const Text("SHIFT TRACKER"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex == 1
          ? null
          : SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () => _onItemTapped(1),
                child: const Icon(Icons.access_time, size: 24),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          shape: _selectedIndex == 1 ? null : const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.list, 0),
              _buildNavItem(Icons.settings_outlined, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.black87 : Colors.grey[400],
        size: 24,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}