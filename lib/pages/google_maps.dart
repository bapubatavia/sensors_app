import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late LatLng currentLocationData;
  late StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation();
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

    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        currentLocationData = LatLng(currentLocation.latitude!, currentLocation.longitude!);        
      });
      print(currentLocationData);
    });
  }

  @override
  void dispose() {
    _locationSubscription.cancel(); // Dispose the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocationData, 
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("Current Location"),
            icon: BitmapDescriptor.defaultMarker,
            position: currentLocationData,
          ),
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
        },
      ),
    );
  }
}