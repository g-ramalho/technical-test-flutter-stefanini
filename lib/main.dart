import 'package:flutter/widgets.dart';
import 'package:technical_test_flutter_stefanini/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  
  await NotificationService().initialize();
  await NotificationService().scheduleReminders();
  
  runApp(const App());
}
