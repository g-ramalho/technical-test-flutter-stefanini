import 'package:flutter_test/flutter_test.dart';
import 'package:technical_test_flutter_stefanini/system_datetime.dart';

void main() {
  group('SystemDateTime', () {
    test('asDateTime returns correct DateTime for valid string', () {
      final systemDateTime = SystemDateTime(dateTimeStr: '25/12/2025 14:30:00.0');
      final result = systemDateTime.asDateTime();

      expect(result, DateTime(2025, 12, 25, 14, 30, 0, 0));
    });

    test('asDateTime returns correct DateTime for string with no subsecond precision', () {
      final systemDateTime = SystemDateTime(dateTimeStr: '28/12/2025 13:42:00');
      final result = systemDateTime.asDateTime();

      expect(result, DateTime(2025, 12, 28, 13, 42, 0, 0));
    });

    test('asDateTime throws FormatException for invalid format', () {
      final systemDateTime = SystemDateTime(dateTimeStr: 'invalid-date');
      
      expect(() => systemDateTime.asDateTime(), throwsFormatException);
    });
  });
}
