import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionChart extends StatefulWidget {
  const MotionChart({super.key});

  @override
  State<MotionChart> createState() => _MotionChartState();
}

class _MotionChartState extends State<MotionChart> {
  List<double> magnitudes = [];
  bool isListening = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }



  void _startListening() {
    _subscription = Sensors().magnetometerEventStream().listen((event)  async {
    double x = event.x;
    double y = event.y;
    double z = event.z;

    double magnitude = sqrt(x * x + y * y + z * z);

      setState(() {
        magnitudes.add(magnitude);
      });
    });
    setState(() {
      isListening = true;
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    if (mounted) {
        isListening = false;
    }
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motion Sensor Chart'),
      ),
      body: Center(
        child: isListening
            ? LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: magnitudes.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minX: 0,
                  maxX: magnitudes.length.toDouble() - 1,
                  minY: 0,
                  maxY: magnitudes.isEmpty ? 100 : 50,
                ),
                
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

