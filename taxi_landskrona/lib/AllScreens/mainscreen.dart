// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_landskrona/AllScreens/AllWidgets/Divider.dart';
import 'package:taxi_landskrona/AllScreens/AllWidgets/noDriverAvailableDialog.dart';
import 'package:taxi_landskrona/AllScreens/AllWidgets/progressDialog.dart';
import 'package:taxi_landskrona/AllScreens/LoginScreen.dart';
import 'package:taxi_landskrona/AllScreens/searchScreen.dart';
import 'package:taxi_landskrona/Assistants/assistantMethods.dart';
import 'package:taxi_landskrona/Assistants/geofireAssistant.dart';
import 'package:taxi_landskrona/DataHandler/appData.dart';
import 'package:taxi_landskrona/Models/directionDetails.dart';
import "package:animated_text_kit/animated_text_kit.dart";
import 'package:taxi_landskrona/Models/nearbyAvailableDrivers.dart';
import 'package:taxi_landskrona/configMaps.dart';
import 'package:taxi_landskrona/main.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainscreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPadding0fMap = 0;

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;
  double driverDetailsContainerHeight=0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded=false;

  DatabaseReference rideRequestRef;

  BitmapDescriptor nearByIcon;

  List<NearbyAvailableDrivers> availableDrivers;

  String state="normal";

  StreamSubscription<Event> rideStreamSubscription;

  bool isRequestingPositionDetails=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();

  }
  void saveRideRequest(){
    rideRequestRef=FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp=Provider.of<AppData>(context,listen: false).pickUpLocation;
    var dropOff=Provider.of<AppData>(context,listen: false).dropOffLocation;

    Map pickUpLocMap={
      "latitude":pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap={
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideinfoMap={
      "driver_id":"waiting",
      "payment_method": "cash",
      "pickup":pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };
    
    rideRequestRef.set(rideinfoMap);

    rideStreamSubscription=rideRequestRef.onValue.listen((event) {
      if(event.snapshot.value==null)
        {
          return;
        }
      if(event.snapshot.value["car_details"]!=null)
      {
        setState(() {
          carDetailsOfDriver=event.snapshot.value["car_details"].toString();
        });
      }
      if(event.snapshot.value["driver_name"]!=null)
      {
        setState(() {
          driverName=event.snapshot.value["driver_name"].toString();
        });
      }
      if(event.snapshot.value["driver_phone"]!=null)
      {
        setState(() {
          driverPhone=event.snapshot.value["driver_phone"].toString();
        });
      }
      if(event.snapshot.value["driver_location"] != null)
      {
        double driverLat=double.parse(event.snapshot.value["driver_location"]["latitude"].toString());
        double driverLng=double.parse(event.snapshot.value["driver_location"]["longitude"].toString());
        LatLng driverCurrentLocation=LatLng(driverLat, driverLng);

        if(statusRide=="accepted")
        {
          updateRideTimeToPickUpLoc(driverCurrentLocation);

        }
        else if(statusRide=="onride")
          {
            updateRideTimeToDropOffLoc(driverCurrentLocation);
          }
        else if(statusRide=="arrived")
        {
          setState(() {
            rideStatus="Driver has Arrived";
          });
        }
      }
      if(event.snapshot.value["status"]!=null)
        {
          statusRide=event.snapshot.value["status"].toString();
        }
      if(statusRide=="accepted")
        {
          displayDriverDetailsContainer();
          Geofire.stopListener();
          deleteGeofireMarkers();
        }
    });
  }

  void deleteGeofireMarkers()
  {
    setState(() {
      markerSet.removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }

  void updateRideTimeToPickUpLoc(LatLng driverCurrentLocation) async
  {
    if(isRequestingPositionDetails==false)
      {
        isRequestingPositionDetails=true;

        var positionUserLatLng=LatLng(currentPosition.latitude,currentPosition.longitude);
        var details=await AssistantMethods.obtainPlaceDirectionDetails(driverCurrentLocation, positionUserLatLng);
        if(details==null)
        {
          return;
        }
        setState(() {
          rideStatus="Driver is Coming - "+details.durationText;
        });

        isRequestingPositionDetails=false;
      }
  }

  void updateRideTimeToDropOffLoc(LatLng driverCurrentLocation) async
  {
    if(isRequestingPositionDetails==false)
    {
      isRequestingPositionDetails=true;

      var dropOff=Provider.of<AppData>(context,listen: false).dropOffLocation;
      var dropOffUserLatLng=LatLng(dropOff.latitude,dropOff.longitude);

      var details=await AssistantMethods.obtainPlaceDirectionDetails(driverCurrentLocation, dropOffUserLatLng);
      if(details==null)
      {
        return;
      }
      setState(() {
        rideStatus="Going to Destination- "+details.durationText;
      });

      isRequestingPositionDetails=false;
    }
  }
  void cancelRideRequest()
  {
    rideRequestRef.remove();
    setState(() {
      state="normal";
    });
  }

  void displayRequestRideContainer()
  {
    setState(() {
      requestRideContainerHeight=250.0;
      rideDetailsContainerHeight=0;
      bottomPadding0fMap=230.0;
      drawerOpen=true;
    });
  }

  void displayDriverDetailsContainer()
  {
    setState(() {
      requestRideContainerHeight=0.0;
      rideDetailsContainerHeight=0.0;
      bottomPadding0fMap=290.0;
      driverDetailsContainerHeight=310.0;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight=0;
      bottomPadding0fMap = 230.0;

      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }



  void displayRideDetailContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPadding0fMap = 230.0;
      drawerOpen = false;
    });

    saveRideRequest();
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

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your Address :: " + address);

    initGeoFireListener();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/profile-icon-png-910.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            FirebaseAuth.instance.currentUser.displayName.toString(),
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Raleway"),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),

              SizedBox(
                height: 12.0,
              ),
              //drawer body controllers

              GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout_sharp),
                  title: Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPadding0fMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPadding0fMap = 300.0;
              });

              locatePosition();
            },
          ),

          //Hamburger button
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          //Search UI
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: searchContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          "Hi there, ",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          "Where to? ",
                          style:
                              TextStyle(fontSize: 20.0, fontFamily: "Raleway"),
                        ),
                        SizedBox(height: 20.0),

                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchScreen()));
                            if (res == "obtainDirection") {
                              displayRideDetailContainer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text("Search Drop Off")
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.0),
                        Row(
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Provider.of<AppData>(context)
                                            .pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickUpLocation
                                        .placeName
                                    : "Add Home"),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text("Your living Home address",
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontSize: 12.0)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),

                        DividerWidget(),

                        SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.work,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add Work"),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text("Your office address",
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontSize: 12.0)),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),

          //Ride Details Ui
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.tealAccent[100],
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(children: [
                                Image.asset(
                                  "images/service-car-icon-png-2414.png",
                                  height: 40.0,
                                  width: 80.0,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Car",
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Raleway")),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : ""),
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  ((tripDirectionDetails != null)
                                      ? "\$${AssistantMethods.calculateFares(tripDirectionDetails)}"
                                      : ''),
                                  style: TextStyle(
                                      fontSize: 20.0, fontFamily: "Raleway"),
                                ),
                              ])),
                        ),
                        SizedBox(height: 20.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_money_sharp,
                                size: 18.0,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 16.0),
                              Text("Cash"),
                              SizedBox(
                                width: 6.0,
                              ),
                              Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black54, size: 16.0),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.0),


                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                state="requesting";
                              });
                              print("Request button click");
                              displayRequestRideContainer();
                              availableDrivers = GeofireAssistant.nearbyAvailableDriversList;
                              searchNearestDriver();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context)
                                  .colorScheme
                                  .primary, // background
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
                                  "Request",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  Icons.local_taxi_rounded,
                                  color: Colors.white,
                                  size: 30.0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

          //Request or Cancel UI
          Positioned(
            bottom:0.0,
            left:0.0,
            right:0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]
              ),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 40.0),


                    SizedBox(
                      width: double.infinity,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          fontFamily: "Raleway",
                        ),
                        textAlign: TextAlign.center,
                        child: Center(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              WavyAnimatedText('Requesting a Ride'),
                              WavyAnimatedText('Please Wait'),
                              WavyAnimatedText('Finding a Driver'),
                            ],

                            isRepeatingAnimation: true,
                            onTap: () {
                              print("Tap Event");
                            },

                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22.0),


                    GestureDetector(
                      onTap: (){
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height:60.0,
                        width:60.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(26.0),
                          border:Border.all(width: 2.0,color:Colors.white),
                        ),
                        child: Icon(Icons.close,size: 26.0,color: Colors.white,),
                      ),
                    ),

                    SizedBox(height:10.0),
                    Container(
                      width:double.infinity,
                      child: Text("Cancel Ride", textAlign:TextAlign.center,style: TextStyle(fontSize: 12.0),),
                    )
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]
              ),
              height: driverDetailsContainerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center ,
                      children: [
                        SizedBox(height: 6.0,),

                        Text(rideStatus, textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0,fontFamily: "Raleway"),),

                      ],
                    ),
                    SizedBox(height: 22.0,),

                    Divider(height: 2.0,thickness: 2.0,),
                    SizedBox(height: 22.0,),

                    Text(carDetailsOfDriver, style: TextStyle(color: Colors.grey),),

                    Text(driverName, style: TextStyle(fontSize: 20.0),),

                    SizedBox(height: 22.0,),

                  ],
                ),
              ),


            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialoq(
              message: "Please Wait....",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);
    print("This is Encoded Points::  ");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: "my location"),
        position: pickUpLatLng,
        markerId: MarkerId("pickUpId"));
    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "Drop Off Location"),
        position: dropOffLatLng,
        markerId: MarkerId("dropOffId"));
    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.transparent,
      center: pickUpLatLng,
      radius: 5,
      strokeWidth: 4,
      strokeColor: Colors.lightBlueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.transparent,
      center: dropOffLatLng,
      radius: 5,
      strokeWidth: 4,
      strokeColor: Colors.red,
      circleId: CircleId("dropOffId"),
    );
    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void initGeoFireListener(){
    
    Geofire.initialize("availableDrivers");
    // comment

    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 15).listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers=NearbyAvailableDrivers();
            nearbyAvailableDrivers.key=map["key"];
            nearbyAvailableDrivers.latitude=map["latitude"];
            nearbyAvailableDrivers.longitude=map["longitude"];
            GeofireAssistant.nearbyAvailableDriversList.add(nearbyAvailableDrivers);

            if(nearbyAvailableDriverKeysLoaded==true)
              {
                updateAvailableDriversOnMap();
              }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.removeDriverFromList(map["key"]);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers=NearbyAvailableDrivers();
            nearbyAvailableDrivers.key=map["key"];
            nearbyAvailableDrivers.latitude=map["latitude"];
            nearbyAvailableDrivers.longitude=map["longitude"];
            GeofireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
          // Update your key's location
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
          // All Intial Data is loaded
            break;
        }
      }

      setState(() {});
      //comment
    });
    // comment
  }

  void updateAvailableDriversOnMap()
  {
    setState(() {
      markerSet.clear();
    });

    Set<Marker> tMarkers=Set<Marker>();

    for(NearbyAvailableDrivers driver in GeofireAssistant.nearbyAvailableDriversList){
      LatLng driverAvailablePosition=LatLng(driver.latitude, driver.longitude);

      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position:driverAvailablePosition,
        icon: nearByIcon,
        rotation: AssistantMethods.createRandomNumber(360),
      );
      tMarkers.add(marker);
    }
    setState(() {
      markerSet=tMarkers;
    });
  }


  void createIconMarker()
  {
    if(nearByIcon==null)
      {
        ImageConfiguration imageConfiguration=createLocalImageConfiguration(context,size:Size(1, 1));
        BitmapDescriptor.fromAssetImage(imageConfiguration, 'images/car-icon-png-4260.png')
            .then((value){
              nearByIcon=value;
        });
      }
  }

  void noDriverFound()
  {
    showDialog(context: context, barrierDismissible: false,builder: (BuildContext context) => NoDriverAvailableDialog());

  }
  void searchNearestDriver()
  {
    if(availableDrivers.length==0)
      {
        cancelRideRequest();
        resetApp();
        noDriverFound();
        return;
      }

    var driver=availableDrivers[0];
    notifyDriver(driver);
    availableDrivers.removeAt(0);
  }

  void notifyDriver(NearbyAvailableDrivers driver)
  {
    driversRef.child(driver.key).child("newRide").set(rideRequestRef.key);
    driversRef.child(driver.key).child("token").once().then((DataSnapshot snap){
      if(snap!=null)
        {
          String token=snap.value.toString();
          AssistantMethods.sendNotificationToDriver(token, context, rideRequestRef.key);
        }
      else
        {
          return;
        }
      const oneSecondPassed=Duration(seconds:1);
      var timer=Timer.periodic(oneSecondPassed, (timer) {
        if (state!="requesting")
          {
            driversRef.child(driver.key).child("newRide").set("cancelled");
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeout=40;
            timer.cancel();
          }

        driverRequestTimeout=driverRequestTimeout-1;

        driversRef.child(driver.key).child("newRide").onValue.listen((event) {
          if(event.snapshot.value.toString()=="accepted")
            {
              driversRef.child(driver.key).child("newRide").onDisconnect();
              driverRequestTimeout=40;
              timer.cancel();
            }
        });


        if(driverRequestTimeout==0)
          {
              driversRef.child(driver.key).child("newRide").set("timeout");
              driversRef.child(driver.key).child("newRide").onDisconnect();
              driverRequestTimeout=40;
              timer.cancel();

              searchNearestDriver();
          }
      });
    });
  }
}
