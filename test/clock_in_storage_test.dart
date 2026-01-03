import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Clock-in Storage Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('_saveClockIn should save clock-in to SharedPreferences', () async {
      final testDateTime = DateTime(2024, 1, 15, 9, 30, 45);
      
      await saveClockIn(testDateTime);
      
      final history = prefs.getStringList('clock_in_history');
      expect(history, isNotNull);
      expect(history!.length, 1);
      expect(history[0], testDateTime.toIso8601String());
    });

    test('_saveClockIn should append multiple clock-ins', () async {
      final dt1 = DateTime(2024, 1, 15, 9, 0, 0);
      final dt2 = DateTime(2024, 1, 15, 13, 0, 0);
      final dt3 = DateTime(2024, 1, 15, 18, 0, 0);
      
      await saveClockIn(dt1);
      await saveClockIn(dt2);
      await saveClockIn(dt3);
      
      final history = prefs.getStringList('clock_in_history');
      expect(history, isNotNull);
      expect(history!.length, 3);
      expect(history[0], dt1.toIso8601String());
      expect(history[1], dt2.toIso8601String());
      expect(history[2], dt3.toIso8601String());
    });

    test('_loadClockIns should load only today\'s clock-ins', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));
      
      final todayEntry1 = DateTime(today.year, today.month, today.day, 9, 0, 0);
      final todayEntry2 = DateTime(today.year, today.month, today.day, 13, 0, 0);
      final yesterdayEntry = DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 0, 0);
      final tomorrowEntry = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0, 0);
      
      await prefs.setStringList('clock_in_history', [
        yesterdayEntry.toIso8601String(),
        todayEntry1.toIso8601String(),
        todayEntry2.toIso8601String(),
        tomorrowEntry.toIso8601String(),
      ]);
      
      final loadedClockIns = await loadClockIns();
      
      expect(loadedClockIns.length, 2);
      expect(loadedClockIns[0], todayEntry1);
      expect(loadedClockIns[1], todayEntry2);
    });

    test('_loadClockIns should return sorted clock-ins', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final entry1 = DateTime(today.year, today.month, today.day, 18, 0, 0);
      final entry2 = DateTime(today.year, today.month, today.day, 9, 0, 0);
      final entry3 = DateTime(today.year, today.month, today.day, 13, 30, 0);
      
      await prefs.setStringList('clock_in_history', [
        entry1.toIso8601String(),
        entry2.toIso8601String(),
        entry3.toIso8601String(),
      ]);
      
      final loadedClockIns = await loadClockIns();
      
      expect(loadedClockIns.length, 3);
      expect(loadedClockIns[0], entry2); // 9:00
      expect(loadedClockIns[1], entry3); // 13:30
      expect(loadedClockIns[2], entry1); // 18:00
    });

    test('_loadClockIns should return empty list when no history exists', () async {
      final loadedClockIns = await loadClockIns();
      
      expect(loadedClockIns, isEmpty);
    });

    test('save and load integration test', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final clockIn1 = DateTime(today.year, today.month, today.day, 8, 30, 0);
      final clockIn2 = DateTime(today.year, today.month, today.day, 12, 45, 30);
      final clockIn3 = DateTime(today.year, today.month, today.day, 17, 15, 15);
      
      // Save clock-ins
      await saveClockIn(clockIn1);
      await saveClockIn(clockIn2);
      await saveClockIn(clockIn3);
      
      // Load and verify
      final loaded = await loadClockIns();
      
      expect(loaded.length, 3);
      expect(loaded[0], clockIn1);
      expect(loaded[1], clockIn2);
      expect(loaded[2], clockIn3);
    });
  });
}

// Helper functions that mirror the app's logic
Future<void> saveClockIn(DateTime dt) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> history = prefs.getStringList('clock_in_history') ?? [];
  history.add(dt.toIso8601String());
  await prefs.setStringList('clock_in_history', history);
}

Future<List<DateTime>> loadClockIns() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> history = prefs.getStringList('clock_in_history') ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return history
      .map((e) => DateTime.parse(e))
      .where((dt) {
    final date = DateTime(dt.year, dt.month, dt.day);
    return date.isAtSameMomentAs(today);
  })
      .toList()
    ..sort((a, b) => a.compareTo(b));
}
