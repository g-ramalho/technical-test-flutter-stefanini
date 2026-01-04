enum ClockInType {
  shiftStart,
  lunchStart,
  lunchEnd,
  shiftEnd,
  additional,
}

extension ClockInTypeExtension on ClockInType {
  String get label {
    switch (this) {
      case ClockInType.shiftStart:
        return 'Shift Start';
      case ClockInType.lunchStart:
        return 'Lunch Start';
      case ClockInType.lunchEnd:
        return 'Lunch End';
      case ClockInType.shiftEnd:
        return 'Shift End';
      case ClockInType.additional:
        return 'Additional';
    }
  }

  int get index {
    switch (this) {
      case ClockInType.shiftStart:
        return 0;
      case ClockInType.lunchStart:
        return 1;
      case ClockInType.lunchEnd:
        return 2;
      case ClockInType.shiftEnd:
        return 3;
      case ClockInType.additional:
        return 4;
    }
  }

  static ClockInType fromIndex(int index) {
    switch (index) {
      case 0:
        return ClockInType.shiftStart;
      case 1:
        return ClockInType.lunchStart;
      case 2:
        return ClockInType.lunchEnd;
      case 3:
        return ClockInType.shiftEnd;
      default:
        return ClockInType.additional;
    }
  }
}
