// @dart=2.9

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxidriverapp/AllScreens/RegistrationScreen.dart';
import 'package:taxidriverapp/Models/drivers.dart';
import 'package:taxidriverapp/Notifications/pushNotificationService.dart';
import 'package:taxidriverapp/configMaps.dart';
import 'package:taxidriverapp/main.dart';


class HomeTabPage extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;

  bool _hasBeenPressed = false;


  String driverStatusText="You are offline";
  Color driverStatusColor=Colors.red;
  bool isDriverAvailable=false;

  var geoLocator = Geolocator();

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatposition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
    new CameraPosition(target: latLatposition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address =
    // await AssistantMethods.searchCoordinateAddress(position, context);
    // print("This is your Address :: " + address);
  }

  void getCurrentDriverInfo() async
  {
    currentFirebaseUser=await FirebaseAuth.instance.currentUser;

    driverRef.child(currentFirebaseUser.uid).once().then((DataSnapshot dataSnapShot)
    {
      if(dataSnapShot!=null)
        {
          driversInformation=Drivers.fromSnapshot(dataSnapShot);
        }
    });
    PushNotificationService pushNotificationService=PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [


        GoogleMap(
          padding: EdgeInsets.only(top: 150),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locatePosition();
          },
        ),

        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),

        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if(isDriverAvailable!=true)
                      {
                        makeDriverOnlineNow();
                        getLocationLiveUpdates();

                        setState(() {
                          driverStatusColor=Colors.green;
                          driverStatusText="Now you are online!";
                          isDriverAvailable=true;
                        });
                          displayToastMessage("You are now Online!", context);
                      }
                    else
                      {
                        makeDriverOfflineNow();
                        setState(() {
                          driverStatusColor=Colors.red;
                          driverStatusText="You are offline";
                          isDriverAvailable=false;
                        });
                        displayToastMessage("You are now Offline!", context);
                      }


                  },
                  style: ElevatedButton.styleFrom(
                    primary: driverStatusColor, // background
                    onPrimary: Theme.of(context)
                        .colorScheme
                        .secondary, // foreground
                    shape: new RoundedRectangleBorder(
                      borderRadius:
                      new BorderRadius.all(Radius.circular(5.0)),
                    ),
                    padding: EdgeInsets.all(17.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        driverStatusText,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Icon(
                        Icons.toggle_on_outlined,
                        color: Colors.black,
                        size: 35.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async
  {

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");

    Geofire.setLocation(FirebaseAuth.instance.currentUser.uid, currentPosition.latitude, currentPosition.longitude);

    rideRequestRef.set("searching");
    rideRequestRef.onValue.listen((event) {

    });
  }

  void getLocationLiveUpdates()
  {
    homeTabPageStreamSubscription=Geolocator.getPositionStream().listen((Position position){
      currentPosition=position;

      if (isDriverAvailable==true)
        {
          Geofire.setLocation(FirebaseAuth.instance.currentUser.uid, position.latitude, position.longitude);
        }
      LatLng latLng=LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef=null;

  }
}
