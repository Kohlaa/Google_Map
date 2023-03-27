import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class homeScreen extends StatefulWidget {
  static const String routeName = 'home-screen';

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  Location location = Location();
  late PermissionStatus permissionStatus;
  bool serviceEnabled = false;
  LocationData? locationData;

  Set<Marker> markers = {};

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  double defLat = 43.4140383;
  double defLong = -118.945615;

  StreamSubscription<LocationData>? locationStream;

  @override
  void initState() {
    super.initState();
    getUserLocation();
    var userMarker = Marker(
      markerId: MarkerId('User location'),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLong),
    );
    markers.add(userMarker);

    // Start tracking the user's location
    // trackUserLocation();
  }

  @override
  void dispose() {
    locationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
        centerTitle: true,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
        onTap: (latLng) => updateUserMarker(latLng),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToUserLocation,
        label: Text('My Location'),
        icon: Icon(Icons.my_location),
      ),
    );
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  void getUserLocation() async {
    bool permissionGranted = await isPermissionGranted();
    bool gpsEnabled = await isServiceEnabled();

    if (permissionGranted && gpsEnabled) {
      locationData = await location.getLocation();
      locationStream = location.onLocationChanged.listen((newLocationData) {
        if (newLocationData.latitude != null &&
            newLocationData.longitude != null &&
            newLocationData.latitude != locationData?.latitude &&
            newLocationData.latitude != locationData?.longitude) {
          locationData = newLocationData;
          updateUserMarker(
              LatLng(locationData!.latitude!, locationData!.longitude!));
          print(
              '${locationData?.latitude ?? 0} , ${locationData?.longitude ??
                  0}');
        }
      });
    }
  }

  void updateUserMarker(LatLng latLng) async {
    var userMarker = Marker(
      markerId: MarkerId('User location'),
      position: latLng,
    );
    markers.add(userMarker);
    setState(() {});
    // var controller = await _controller.future;
    var newCameraPosition = CameraPosition(
      target: latLng,
      zoom: 19,
    );
    // controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  // void goToUserLocation() async {
  //   if (locationData != null) {
  //     var userLatLng =
  //     LatLng(locationData!.latitude!, locationData!.longitude!);
  //     updateUserMarker(userLatLng);
  //     var controller = await _controller.future;
  //     var newCameraPosition = CameraPosition(target: userLatLng, zoom: 19);
  //     controller
  //         .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  //   }
  // }
  void goToUserLocation() async {
    if (locationData != null) {
      var userLatLng = LatLng(locationData!.latitude!, locationData!.longitude!);

      // Remove the previous user marker
      markers.removeWhere((marker) => marker.markerId.value == 'User location');

      // Add a new marker at the updated position
      var userMarker = Marker(
        markerId: MarkerId('User location'),
        position: userLatLng,
      );
      markers.add(userMarker);

      // Update the camera position
      var controller = await _controller.future;
      var newCameraPosition = CameraPosition(target: userLatLng, zoom: 19);
      controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));

      setState(() {});
    }
  }



  void trackUserLocation() {
    locationStream = location.onLocationChanged.listen((newLocationData) {
      if (newLocationData.latitude != null &&
          newLocationData.longitude != null &&
          newLocationData.latitude != locationData?.latitude &&
          newLocationData.latitude != locationData?.longitude) {
        locationData = newLocationData;
        updateUserMarker(
            LatLng(locationData!.latitude!, locationData!.longitude!));
        print(
            '${locationData?.latitude ?? 0} , ${locationData?.longitude ?? 0}');
      }
    });
  }
}
