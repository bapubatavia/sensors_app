import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:fl_chart/fl_chart.dart';

class SmartLights extends StatefulWidget {
  const SmartLights({super.key});

  @override
  State<SmartLights> createState() => _SmartLightsState();
}

class _SmartLightsState extends State<SmartLights> {
  List<double> luxValues = [];
  bool isListening = false;
  StreamSubscription? _subscription;
  bool notificationSent = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }



  void _startListening() {
    _subscription = LightSensor.luxStream().listen((lux) async {
      setState(() {
        luxValues.add(lux.toDouble());
      });
      if(lux > 3000 && !notificationSent){
        await triggerNotification();
        notificationSent = true;
      } else if (lux < 3000) {
        notificationSent = false;
      }
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
        title: const Text('Light Sensor Chart'),
      ),
      body: Center(
        child: isListening
            ? LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: luxValues.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minX: 0,
                  maxX: luxValues.length.toDouble() - 1,
                  minY: 0,
                  maxY: luxValues.isEmpty ? 100 : luxValues.reduce((a, b) => a > b ? a : b) * 1.2,
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Future<void> triggerNotification() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: 'basic_channel',
        title: 'Wow it just got a whole lot brighter!!',
        body: "Seems like you're in a very bright place! The Light Sensor chart is reading over 3000 lux unit!!",
      )
    );
  }
}

