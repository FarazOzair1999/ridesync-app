// @dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxidriverapp/Assistants/requestAssistant.dart';
import 'package:taxidriverapp/DataHandler/appData.dart';
import 'package:taxidriverapp/Models/address.dart';
import 'package:taxidriverapp/Models/allUsers.dart';
import 'package:taxidriverapp/Models/directionDetails.dart';
import 'package:taxidriverapp/configMaps.dart';

class AssistantMethods
{
  // static Future<String> searchCoordinateAddress(Position position,context) async
  // {
  //   String placeAddress="";
  //   final coordinates = new Coordinates(position.latitude, position.longitude);
  //   var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   placeAddress = addresses.first.featureName +","+addresses.first.subLocality+","+ addresses.first.subAdminArea;
  //
  //   Addressforuser userPickUpAddress=new Addressforuser();
  //   userPickUpAddress.longitude=position.longitude;
  //   userPickUpAddress.latitude=position.latitude;
  //   userPickUpAddress.placeName=placeAddress;
  //
  //   Provider.of<AppData>(context,listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //   return placeAddress;
  //
  // }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialposition, LatLng finalposition) async
  {
    String directionUrl="https://maps.googleapis.com/maps/api/directions/json?origin=${initialposition.latitude},${initialposition.longitude}&destination=${finalposition.latitude},${finalposition.longitude}&key=$mapKey";
    var res= await RequestAssistant.getRequest(directionUrl);

    if(res=="failed")
      {
        return null;
      }
    DirectionDetails directionDetails=DirectionDetails();

    directionDetails.encodedPoints=res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText=res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue=res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText=res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue=res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;


  }
  static double calculateFares(DirectionDetails directionDetails)
  {
    //in terms of USD
    double timeTravelledFare=(directionDetails.durationValue / 60) * 0.38;
    double distanceTravelledFare=(directionDetails.distanceValue / 1000) * 1.28;
    double bookingFee=3;
    double totalFareAmount = timeTravelledFare + distanceTravelledFare + bookingFee;
    totalFareAmount=num.parse(totalFareAmount.toStringAsFixed(2));
    return totalFareAmount;
  }

  // static void getCurrentOnlineUserInfo() async{
  //   firebaseUser=await FirebaseAuth.instance.currentUser;
  //
  //   String userId=firebaseUser.uid;
  //   DatabaseReference reference= FirebaseDatabase.instance.reference().child("users").child(userId);
  //
  //   reference.once().then((DataSnapshot dataSnapShot){
  //     if(dataSnapShot.value!=null)
  //       {
  //         userCurrentInfo=Users.fromSnapshot(dataSnapShot);
  //       }
  //   });
  // }

  static void disablehomeTabLocationLiveUpdates()
  {
    homeTabPageStreamSubscription.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void enablehomeTabLocationLiveUpdates()
  {
    homeTabPageStreamSubscription.resume();
    Geofire.setLocation(currentFirebaseUser.uid,currentPosition.latitude,currentPosition.longitude);
  }
}