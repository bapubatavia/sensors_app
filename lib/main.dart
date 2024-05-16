import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:sensors_app/pages/Main_page.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel', 
          channelName: 'Bsic notifications', 
          channelDescription: 'Notification channel for basic tests',
        )
      ],
      debug: true,
    );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<MyApp> createState() => _MainAppState();
}

class _MainAppState extends State<MyApp> {
  late StreamSubscription<AccelerometerEvent> _accelerometerSub;
  bool movementNotificationSent = false;
  bool _isNear = false;

 @override
  void initState() {
    super.initState();
    listenSensor();
    _accelerometerSub = accelerometerEvents.listen(_handleAccelerometerEvent);
  }

  @override
  void dispose() {
    
    _accelerometerSub.cancel();
    super.dispose();
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) async {
    double x = event.x;
    double y = event.y;
    double z = event.z;

    double magnitude = sqrt(x * x + y * y + z * z);

    double threshold = 30.0;

    if (magnitude > threshold && !movementNotificationSent) {

        await triggerNotification();
        movementNotificationSent = true;
      } else if (magnitude < threshold) {
        movementNotificationSent = false;
      }
    }

  Future<void> listenSensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    await ProximitySensor.setProximityScreenOff(true).onError((error, stackTrace) {
      print("could not enable screen off functionality");
      return null;
    });

    ProximitySensor.events.listen((int event) {
      setState(() {
        _isNear = (event > 0) ? true : false;
      });
      print(_isNear);
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> triggerNotification() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: 'basic_channel',
        title: 'Unepxpected Movement detected!',
        body: "WARNING, WARNING! Please be more careful with your phone!",
      )
    );
  }
}
