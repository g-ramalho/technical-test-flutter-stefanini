import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:technical_test_flutter_stefanini/ponto_certificado_api.dart';

class SystemDateTime {
  final String dateTimeStr;

  const SystemDateTime({required this.dateTimeStr});

  factory SystemDateTime.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"d": String d} => SystemDateTime(
        dateTimeStr: d,
      ),
      _ => throw const FormatException("Failed to construct SystemDateTime from API response"),
    };
  }

  DateTime asDateTime() {
    if (dateTimeStr.contains(".")) {
      return DateFormat("dd/MM/yyyy HH:mm:ss.S").parse(dateTimeStr);
    }
    return DateFormat("dd/MM/yyyy HH:mm:ss").parse(dateTimeStr);
  }
}

Future<SystemDateTime> fetchDateTime(String apiEndpointUrl) async {
  final Response r = await PontoCertificadoApi(apiEndpointUrl).fetchSystemTime();

  if (r.statusCode == 200) {
    return SystemDateTime.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  } else {
    throw Exception("Response from API had unsuccessful status code");
  }
}