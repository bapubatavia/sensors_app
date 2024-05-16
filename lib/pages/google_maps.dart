import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;
import 'package:location/location.dart';
import 'dart:async';


class MyCurrentLocation extends StatefulWidget {
  const MyCurrentLocation({super.key});

  @override
  State<MyCurrentLocation> createState() => _MyCurrentLocationState();
}

class _MyCurrentLocationState extends State<MyCurrentLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  late  PermissionStatus permissionGranted;
  LatLng? currentLocationData;
  late StreamSubscription<LocationData> locationSubscription;


  bool isInTestFence = false;
  bool isInSchoolFence = false;

  bool oldValue = true;
  List<LatLng> polygonTestFence = const [
    LatLng(-1.950906, 30.084516),
    LatLng(-1.951043, 30.084690),
    LatLng(-1.951268, 30.084412),
    LatLng(-1.951132, 30.084267),
    LatLng(-1.950999, 30.084381),

  ];
  List<LatLng> polygonSchoolFence = const [
    LatLng(-1.9553586384001813, 30.104230042760484),
    LatLng(-1.9554303457099977, 30.104283686943276),
    LatLng(-1.9553881255186063, 30.104345377753482),
    LatLng(-1.9553130673979602, 30.104319896766654),
  ];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await getUserCurrentLocation());
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) { 
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }


Future<void> checkUpdatedLocation(LatLng? latLng) async {
  if (latLng != null) {
    setState(() {
      isInTestFence = map_tool.PolygonUtil.containsLocation(
        map_tool.LatLng(latLng.latitude, latLng.longitude),
        polygonTestFence.map((point) => map_tool.LatLng(point.latitude, point.longitude)).toList(),
        false,
      );
      isInSchoolFence = map_tool.PolygonUtil.containsLocation(
        map_tool.LatLng(latLng.latitude, latLng.longitude),
        polygonSchoolFence.map((point) => map_tool.LatLng(point.latitude, point.longitude)).toList(),
        false,
      );
      triggerNotification(isInSchoolFence);
    });
  }
}


  Future<void> getUserCurrentLocation() async {
    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) async {
      setState(() {
        currentLocationData = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });

      await checkUpdatedLocation(currentLocationData);

      print(currentLocationData);
    });
  }

  @override
  void dispose() {
    // Cancel the location subscription to avoid memory leaks
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocationData != null
      ?GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocationData!, 
          zoom: 15,
        ),
        polygons: {
          Polygon(
            polygonId: const PolygonId("fence"),
            points: polygonTestFence,
            strokeWidth: 2,
            fillColor: const Color(0xFF006491).withOpacity(0.2)
          ),
          Polygon(
            polygonId: const PolygonId("School Fence"),
            points: polygonSchoolFence,
            strokeWidth: 2,
            fillColor: const Color(0xFF006491).withOpacity(0.2)
          ),
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
        },
      )
    : const Center(child: CircularProgressIndicator())
    );
  }

  Future<void> triggerNotification(bool insideIt) async {
    if(insideIt != oldValue){
      if(insideIt == false){
        oldValue = insideIt;
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10, 
            channelKey: 'basic_channel',
            title: 'Outside the fence!',
            body: "Alert: It seems someone's stepped beyond the boundaries. Time to comeback within the comfort zone. 🚶🔙 #SafetyFirst #StayCloseBy",
          )
        );
      }
      if(insideIt == true){
        oldValue = insideIt;
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 11, 
            channelKey: 'basic_channel',
            title: 'Back inside the fence!',
            body: "Welcome back! Looks like someone's returned to the fold. Home sweet home, indeed! 🏠🎉 #BackInTheZone #SafeAndSound",
          )
        );
      }
    }
  }
}