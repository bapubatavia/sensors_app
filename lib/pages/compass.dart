import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class MyCompass extends StatefulWidget {
  const MyCompass({super.key});

  @override
  State<MyCompass> createState() => _MyCompassState();
}

class _MyCompassState extends State<MyCompass> {
  double? heading = 0;
  late StreamSubscription<CompassEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FlutterCompass.events?.listen((event) {
      setState(() {
        heading = event.heading;
      });
     });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  AppBar(
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
        title: const Text("Compass"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${heading!.ceil()}°", 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 26.0, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/img/cadrant.png"),
                Transform.rotate(
                  angle: ((heading ?? 0) * (pi / 180) * 1),
                  child: Image.asset(
                    "assets/img/compass.png",
                    scale: 1.1,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}