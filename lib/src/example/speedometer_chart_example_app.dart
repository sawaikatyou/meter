import 'package:flutter/material.dart';
import 'package:speedometer_chart/speedometer_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double value = 20;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PluginXXX example app'),
        ),
        body: Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10, // 100
            runSpacing: 5, // 50
            children: [
              SpeedometerChart(
                value: value,
                graphColor: const [Colors.blue, Colors.lightBlueAccent],
                hasIconPointer: true,
                pointerColor: Colors.red,
                valueWidget: Text('${value.toDouble()}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
