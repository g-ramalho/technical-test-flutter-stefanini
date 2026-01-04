import 'package:flutter/material.dart';
import 'package:technical_test_flutter_stefanini/models/clock_in_type.dart';

class ShiftReminder {
  final ClockInType type;
  final TimeOfDay scheduledTime;
  final int minutesBefore;

  ShiftReminder({
    required this.type,
    required this.scheduledTime,
    required this.minutesBefore,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'hour': scheduledTime.hour,
      'minute': scheduledTime.minute,
      'minutesBefore': minutesBefore,
    };
  }

  static ShiftReminder fromJson(Map<String, dynamic> json) {
    return ShiftReminder(
      type: ClockInTypeExtension.fromIndex(json['type'] as int),
      scheduledTime: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      minutesBefore: json['minutesBefore'] as int,
    );
  }
}
