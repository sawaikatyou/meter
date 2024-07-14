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
    double value = 40;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10, // 100
            runSpacing: 5, // 50
            children: [
              SpeedometerChart(
                value: value,
                graphColor: const [Colors.blueAccent, Colors.lightBlueAccent],
              ),
              SpeedometerChart.tick(
                value: value,
              ),
              SpeedometerChart.tick(
                value: value,
                valueWidget: Text(value.toString()),
                hasTickSpace: true,
                hasIconPointer: false,
              ),
              SpeedometerChart(
                value: value,
                valueWidget: Text(value.toString()),
                hasIconPointer: false,
                pointerColor: Colors.tealAccent,
                graphColor: const [Colors.deepPurple, Colors.orange],
                minWidget: const Text("Min value: 0"),
                maxWidget: const Text("Max value: 100"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
