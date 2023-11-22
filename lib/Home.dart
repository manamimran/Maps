import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/src/places.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng currentLocation = LatLng(31.522471087034276, 74.43903826663447);
  late GoogleMapController mapController;
  final TextEditingController search_controller = TextEditingController();
  Map<String, Marker> mapMarkers = {};
  LatLng latlng_center = LatLng(0.0, 0.0); //The LatLng representing the visible center of the map.
  late Timer time_debounce; //A timer for debouncing camera move events.
  String visibleAddress = "";
  

  final ApiKey = "AIzaSyDielMrqePDtgCxZUHSbWkKr4SyTZjXWAk";

  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: "AIzaSyDielMrqePDtgCxZUHSbWkKr4SyTZjXWAk");

  @override
  void initState() {
    super.initState();
    time_debounce = Timer(Duration(milliseconds: 500), () {});
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
                    addMarker('Added', LatLng(lat, lng),visibleAddress); // Pass the required parameters
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
      // key: homeScaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                showPlacesAutocomplete();        //google place function
              },
              child: Text('Search'),
            ),
            SizedBox(
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
                  // Update the visible address when the user stops moving the map
                  updateVisibleAddress();

                  // // Add a marker when the user stops moving the map
                  //  LatLng centerPoint = await getVisibleCenter(); //getVisibleCenter is a method that calculates and returns the LatLng coordinates of the center of the visible region on the map.
                  //  addMarker("Current", centerPoint);
                  //  setState(() {
                  // latlng_center = centerPoint; // placing getting latlng_center equal to obtained latlng of visible center through getVisibleCenter method
                  //  });
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
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Address: $visibleAddress',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          allowPermissions();
                          addMarker('id', currentLocation, visibleAddress);
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
    );
  }

  addMarker(String id, LatLng location, String address) async {
    // var markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), "assets/images/marker_map.png");
    var marker = Marker(
      // using id as key
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(title: address),
      // icon: markerIcon,
    );
    mapMarkers[id] = marker;
    setState(() {});
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

  void goToLocation(double lat, double lng) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  Future<String> getVisibleAddress() async {
    LatLngBounds bounds = await mapController.getVisibleRegion();
    double centerLatitude =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    double centerLongitude =
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;

    List<Placemark> placemarks =
    await placemarkFromCoordinates(centerLatitude, centerLongitude);

    if (placemarks.isNotEmpty) {
      Placemark firstPlacemark = placemarks.first;
      String address =
          '${firstPlacemark.subThoroughfare} ${firstPlacemark
          .thoroughfare}, ${firstPlacemark.locality}, ${firstPlacemark
          .administrativeArea} ${firstPlacemark.postalCode}, ${firstPlacemark
          .country}';
      return address;
    } else {
      return "No Address Found";
    }
  }

  Future<void> updateVisibleAddress() async {
    String address = await getVisibleAddress();
    print("Visible Address: $address");

    setState(() {
      visibleAddress = address;
    });
    // Add a marker with the visible address
    addMarker('Current', latlng_center, 'Address: $address');
  }

  Future<void> showPlacesAutocomplete() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: ApiKey,
      onError: (error) {},
      mode: Mode.overlay,
      language: "en",
      decoration: InputDecoration(
        hintText: "Search",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      types: [],
      strictbounds: false,
      components: [
        // Component(Component.country, "pk"),
      ],
    );
    if (p != null) {

      print("Place Id: ${p.placeId}");
      print("Place Description: ${p.description}");

      // Fetch details of the selected place
      PlacesDetailsResponse details =
      await places.getDetailsByPlaceId(p.placeId!);

      // Extract latitude and longitude
      double lat = details.result.geometry!.location.lat;
      double lng = details.result.geometry!.location.lng;

      // Add a marker to the selected location
      addMarker('Selected', LatLng(lat, lng),visibleAddress);
      goToLocation(lat, lng);
    }
  }

}

