// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';


class StepsCounter extends StatefulWidget {
  const StepsCounter({super.key});

  @override
  State<StepsCounter> createState() => _StepsCounterState();
}

class _StepsCounterState extends State<StepsCounter> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  late StreamSubscription<StepCount> _stepCountSubscription;
  late StreamSubscription<PedestrianStatus> _pedestrianStatusSubscription;


  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkPermissions();
  }


Future<void> checkPermissions() async {
  final permissionStatus = await Permission.activityRecognition.status;
  switch (permissionStatus) {
    case PermissionStatus.granted:
      print('Permission granted for activity recognition');
      break;
    case PermissionStatus.denied:
      print('Permission denied for activity recognition');
      await Permission.activityRecognition.request();
      break;
    case PermissionStatus.restricted:
      print('Permission restricted for activity recognition');
      openAppSettings();
      break;
    case PermissionStatus.permanentlyDenied:
      print('Permission permanently denied for activity recognition');
      openAppSettings();
      break;
    default:
      print('Unknown permission status');
  }
}

  

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusSubscription = _pedestrianStatusStream
        .listen(onPedestrianStatusChanged);
    _pedestrianStatusSubscription.onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream.listen(onStepCount);
    _stepCountSubscription.onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  void dispose() {
    // Cancel the subscriptions
    _stepCountSubscription.cancel();
    _pedestrianStatusSubscription.cancel();
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
            children: <Widget>[
              const Text(
                'Step Count:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                _steps,
                style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
            const Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              const Text(
                'Pedestrian Status',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? const TextStyle(fontSize: 30)
                      : const TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      );
  }
}