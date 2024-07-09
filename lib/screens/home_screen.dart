import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:lesson72_location/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng najotTalim = const LatLng(41.2856806, 69.2034646);
  LatLng myCurrentPosition = LatLng(41.2856806, 69.2034646);
  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];
  final TextEditingController _searchController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      var location = await LocationService.getCurrentLocation();
      setState(() {
        myCurrentPosition = LatLng(location.latitude!, location.longitude!);
      });
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      setState(() {
        myCurrentPosition = LatLng(location.latitude!, location.longitude!);
      });
    });
  }

  void addLocationMarker() {
    myMarkers.add(
      Marker(
        markerId: MarkerId(myMarkers.length.toString()),
        position: myCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    myPositions.add(myCurrentPosition);

    if (myPositions.length == 2) {
      LocationService.fetchPolylinePoints(
        myPositions[0],
        myPositions[1],
      ).then((List<LatLng> positions) {
        setState(() {
          polylines.add(
            Polyline(
              polylineId: PolylineId(UniqueKey().toString()),
              color: Colors.blue,
              width: 5,
              points: positions,
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocation = LocationService.currentLocation;

    print("CurrentLocation: $myLocation");

    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              buildingsEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: najotTalim,
                zoom: 16.0,
              ),
              trafficEnabled: true,
              onCameraMove: onCameraMove,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId("myCurrentPosition"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  position: myCurrentPosition,
                  infoWindow: const InfoWindow(),
                ),
                ...myMarkers,
              },
              polylines: polylines,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: GooglePlacesAutoCompleteTextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: "Search",
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.9),
                ),
                textEditingController: _searchController,
                googleAPIKey: "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ",
                debounceTime: 400,
                countries: ["de"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (prediction) {
                  setState(() {
                    myCurrentPosition = LatLng(double.parse(prediction.lat!),
                        double.parse(prediction.lng!));
                  });
                  mapController.animateCamera(
                    CameraUpdate.newLatLng(myCurrentPosition),
                  );
                },
                itmClick: (prediction) {
                  _searchController.text = prediction.description!;
                  _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description!.length));
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: addLocationMarker,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
