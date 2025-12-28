import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:technical_test_flutter_stefanini/ponto_certificado_api.dart';

class SystemDateTime {
  final String dateTimeStr;

  const SystemDateTime({required this.dateTimeStr});

  factory SystemDateTime.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'d': String d} => SystemDateTime(
        dateTimeStr: d.padRight(23, '0').substring(0, 23), // intl only supports up to .999 precision in .parse()
      ),
      _ => throw const FormatException('Failed to construct SystemDateTime from API response'),
    };
  }

  DateTime asDateTime() {
    if (dateTimeStr.contains('.')) {
      return DateFormat('dd/MM/yyyy HH:mm:ss.S').parseStrict(dateTimeStr);
    }
    return DateFormat('dd/MM/yyyy HH:mm:ss').parseStrict(dateTimeStr);
  }
}

Future<SystemDateTime> fetchDateTime() async {
  final Response r = await PontoCertificadoApi('https://wspilotomobile.pontocertificado.com.br/WcfREPV.svc').fetchSystemTime();

  if (r.statusCode == 200) {
    return SystemDateTime.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  } else {
    throw Exception('Response from API had unsuccessful status code');
  }
}