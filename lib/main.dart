import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'global.dart';
import 'package:location/location.dart' as l;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Milo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Marker> allMarkers = [];
  GoogleMapController mapController;
  static LatLng _currentLocation;
  String searchAddr;
  String searchAddr1;
  TextEditingController _locationController = new TextEditingController();
  var location = l.Location();

  Future _checkGps() async {
    if(!await location.serviceEnabled()){
      location.requestService();
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top:false,
          child: Stack(
            children: <Widget>[
              new GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:_currentLocation==null? LatLng(28.4194, 77.0437):_currentLocation,
                  zoom: 15.0,
                ),
                markers: Set.from(allMarkers),
                onMapCreated: mapCreated,
              ),
              Stack(children: <Widget>[
                Container(
                    padding: EdgeInsets.all(40),
                    constraints: BoxConstraints.expand(height: 150),
                    decoration: BoxDecoration(
                        gradient: new LinearGradient(
                            colors: [lightBlueIsh, lightGreen],
                            begin: const FractionalOffset(1.0, 1.0),
                            end: const FractionalOffset(0.2, 0.2),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)))),
                Positioned(
                  top: 10.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: _currentLocation==null? "Loading...":"",
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: searchAndNavigate,
                            iconSize: 30.0,
                          )),
                      controller: _locationController,
                      onChanged: (val){
                        searchAddr = val;
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 80.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText:"Enter Addres #2",
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: searchAndNavigate1,
                            iconSize: 30.0,
                          )),
                      onChanged: (val){
                        searchAddr1=val;
                      },
                    ),
                  ),
                ),
              ]),
              Align(
                alignment: Alignment.bottomRight,
                child:Container(
                  margin: EdgeInsets.only(right:10.0,bottom:60.0),
                  child: FloatingActionButton(
                    child: Icon(Icons.my_location),
                    backgroundColor: Colors.green,
                    onPressed: _getUserLocation,
                  ),
                )
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                        height: 60.0,
                        margin: EdgeInsets.all(20.0),
                        width: 120.0,
                        decoration: BoxDecoration(
                            gradient: new LinearGradient(
                                colors: [ lightGreen,lightBlueIsh],
                                begin: const FractionalOffset(1.0, 1.0),
                                end: const FractionalOffset(0.2, 0.2),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Center(
                            child: Text(
                          "Find Places",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.0),
                        ))),
                    onTap: calculateMean,
                  )
              )],
          )));
  }

  void mapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  calculateMean() {
    double meanLatitude;
    double meanLongitude;
    setState(() {
      meanLatitude = (allMarkers[0].position.latitude.toDouble() +
              allMarkers.last.position.latitude.toDouble()) /
          2;
      meanLongitude = (allMarkers[0].position.longitude.toDouble() +
              allMarkers.last.position.longitude.toDouble()) /
          2;
      Marker mk1 = Marker(
          markerId: MarkerId('3'),
          position: LatLng(meanLatitude, meanLongitude));
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(meanLatitude, meanLongitude),
        zoom: 15.0,
      )));
      allMarkers.add(mk1);
    });
  }
  _getUserLocation() async{
    _checkGps();
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _currentLocation =LatLng(position.latitude,position.longitude);
      _locationController.text=" ${placemark[0].name},${placemark[0].subLocality},${placemark[0].locality},${placemark[0].administrativeArea},${placemark[0].country}";
      print(placemark[0].name);
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
        LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      )));
      Marker mk1 = Marker(
          markerId: MarkerId('1'),
          position:
          LatLng(position.latitude,position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: "Location 1")
      );
      allMarkers.add(mk1);
    });
  }
  searchAndNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) {
      setState(() {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 15.0,
        )));
        Marker mk1 = Marker(
          markerId: MarkerId('1'),
          position:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        );
        allMarkers.add(mk1);
      });
    });
  }
  searchAndNavigate1() {
    Geolocator().placemarkFromAddress(searchAddr1).then((result) {
      setState(() {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 15.0,
        )));
        Marker mk1 = Marker(
          markerId: MarkerId('2'),
          position:
              LatLng(result[0].position.latitude, result[0].position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        );
        allMarkers.add(mk1);
      });
    });
  }
}
