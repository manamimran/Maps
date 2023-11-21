import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng currentLocation = LatLng(31.522471087034276, 74.43903826663447);
  late GoogleMapController mapController;
  Map<String, Marker> mapMarkers = {};
  LatLng latlng_center =
      LatLng(0.0, 0.0); //The LatLng representing the visible center of the map.
  late Timer time_debounce; //A timer for debouncing camera move events.

  @override
  void initState() {
    super.initState();
    time_debounce = Timer(Duration(milliseconds: 500), () {});
  }

  Future<Position> allowPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void goToCurrentLocation() {
    if (currentLocation != null && mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation.latitude,
              currentLocation.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Future<void> showInputDialog(BuildContext context) async {
    TextEditingController lat_Controller = TextEditingController();
    TextEditingController lng_Controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Data Points'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                TextField(
                  controller: lat_Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'LAT Value'),
                ),
                TextField(
                  controller: lng_Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'LNG Value'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String latText = lat_Controller.text;
                String longText = lng_Controller.text;

                if (latText.isNotEmpty && longText.isNotEmpty) {
                  double lat = double.tryParse(latText) ?? 0.0;
                  double lng = double.tryParse(longText) ?? 0.0;

                  if (lat != 0.0 && lng != 0.0) {
                    addMarker('uniqueId', LatLng(lat, lng)); // Pass the required parameters
                    goToLocation(lat, lng);
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    // Handle invalid input
                    print('Invalid input');
                  }
                } else {
                  // Handle empty input
                  print('Empty input');
                }
              },
              child: Text('Add Location'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              SafeArea(
                child: SizedBox(
                  height: 400,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    onCameraMove: (CameraPosition position) {
                      // Update the center while the map is being scrolled
                      time_debounce.cancel();
                      time_debounce = Timer(Duration(milliseconds: 500), () {
                        setState(() {
                          latlng_center = position
                              .target; //latlng_center variable that represents the LatLng coordinates of the visible center of the map.
                        });
                      });
                    },
                    onCameraIdle: () async {
                      // Add a marker when the user stops moving the map
                      LatLng centerPoint =
                          await getVisibleCenter(); //getVisibleCenter is a method that calculates and returns the LatLng coordinates of the center of the visible region on the map.
                      addMarker("markerId", centerPoint);
                      // setState(() {
                      latlng_center =
                          centerPoint; // placing getting latlng_center equal to obtained latlng of visible center through getVisibleCenter method
                      // });
                    },
                    initialCameraPosition: CameraPosition(
                      target: latlng_center, // Default center at (0, 0)
                      zoom: 10.0,
                    ),
                    markers: mapMarkers.values.toSet(),
                  ),
                  // GoogleMap(
                  //   onTap: (LatLng latlng) {
                  //     print('Our LatLng: $latlng');
                  //     // addMarker('2', latlng);
                  //     addMarker('randomMarker', latlng_center);
                  //   },
                  //   initialCameraPosition:
                  //       // CameraPosition(target: currentLocation, zoom: 15),
                  //       CameraPosition(target: _center, zoom: 15),
                  //   onMapCreated: (GoogleMapController controller) {
                  //     mapController = controller;
                  //     addMarker('1', currentLocation);
                  //   },
                  //   markers: mapMarkers.values.toSet(),
                  // ),
                ),
              ),
              SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Visible Center Latitude: ${latlng_center.latitude.toString()}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Visible Center Longitude: ${latlng_center.longitude.toString()}',
                        style: TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            allowPermissions();
                            goToCurrentLocation();
                          },
                          child: Icon(Icons.my_location)),
                      ElevatedButton(
                          onPressed: () {
                            showInputDialog(context);
                          },
                          child: Text('Add'))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ElevatedButton(onPressed: (){
  //   allowPermissions();
  //   goToCurrentLocation();
  // }, child: Icon(Icons.my_location)),
  // ElevatedButton(onPressed: (){
  //   showInputDialog(context);
  // }, child: Text('Add'))
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  addMarker(String id, LatLng location) async {
    // var markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), "assets/images/marker_map.png");
    var marker = Marker(
      // using id as key
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(),
      // icon: markerIcon,
    );
    mapMarkers[id] = marker;
    setState(() {});
  }

  void goToLocation(double lat, double lng) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  Future<LatLng> getVisibleCenter() async {
    // Calculates the center of the visible region using getVisibleRegion from the GoogleMapController
    LatLngBounds bounds = await mapController.getVisibleRegion();      //bounds is the LatLngBounds object representing the visible region of the map.
    double centerLatitude =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;       //bounds.southwest.latitude and bounds.northeast.latitude represent the latitude of the southwest and northeast corners of the visible region.
    double centerLongitude =                                                  //The latitude of the center is calculated as the average of the southwest and northeast latitudes.
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(centerLatitude, centerLongitude);
  }
}
