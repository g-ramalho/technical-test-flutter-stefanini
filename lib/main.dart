import 'package:flutter/material.dart';
import 'package:technical_test_flutter_stefanini/system_datetime.dart';

void main() {
 runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<SystemDateTime> futureSystemDateTime;

  @override
  void initState() {
    super.initState();
    futureSystemDateTime = fetchDateTime("https://wspilotomobile.pontocertificado.com.br/WcfREPV.svc/");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock.in',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Clock.in')),
        body: Center(
          child: FutureBuilder<SystemDateTime>(
            future: futureSystemDateTime,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.dateTimeStr);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

