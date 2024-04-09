import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class StepsCounter extends StatefulWidget {
  const StepsCounter({super.key});

  @override
  State<StepsCounter> createState() => _StepsCounterState();
}

class _StepsCounterState extends State<StepsCounter> {
  int stepCount = 0;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void detectSteps(AccelerometerEvent event) {
    double magnitude = event.x.abs() + event.y.abs() + event.z.abs();
    if (magnitude > 20) {
      setState(() {
        stepCount++;
      });
    }
  }


  void initPlatformState() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      detectSteps(event);
      },
      onError: (dynamic error) {
        print('Error accessing accelerometer data: $error');
      },
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Step Counter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Step Count:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '$stepCount',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
  }
}