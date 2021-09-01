// @dart=2.9
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxidriverapp/Models/rideDetails.dart';
import 'package:taxidriverapp/Notifications/notificationDialog.dart';
import 'package:taxidriverapp/configMaps.dart';
import 'package:taxidriverapp/main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
class PushNotificationService
{

  Future initialize(context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message)
    {
      String data=message.data['ride_request_id'];
      print(data);
      retrieveRideRideRequestInfo(data,context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      String data=message.data['ride_request_id'];
      print(data);
      retrieveRideRideRequestInfo(data,context);
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      String data=message.data['ride_request_id'];
      print(data);
      retrieveRideRideRequestInfo(data,context);
    });
  }

  Future<String> getToken() async{
    String token = await FirebaseMessaging.instance.getToken();
    print("This is token::");
    print(token);
    driverRef.child(currentFirebaseUser.uid).child("token").set(token);

    FirebaseMessaging.instance.subscribeToTopic("alldrivers");
    FirebaseMessaging.instance.subscribeToTopic("allusers");
  }

  // RemoteMessage getRideRequestId(RemoteMessage message)
  // {
  //   RemoteMessage rideRequestId;
  //   if(Platform.isAndroid)
  //     {
  //       print("this is ride request id:");
  //       rideRequestId = message['data']['ride_request_id'];
  //       print(rideRequestId);
  //     }
  //   // else
  //   //   {
  //   //     print("this is ride request id:");
  //   //     rideRequestId=RemoteMessage.fromMap(message['ride_request_id']);
  //   //     print(rideRequestId);
  //   //   }
  //   return rideRequestId;
  // }
  void retrieveRideRideRequestInfo(String riderequestId,BuildContext context)
  {
    newRequestRef.child(riderequestId).once().then((DataSnapshot dataSnapShot)
    {
        if(dataSnapShot.value!=null)
          {
            FlutterRingtonePlayer.playRingtone(looping: true);

            double pickUpLocationLat=double.parse(dataSnapShot.value["pickup"]["latitude"].toString());
            double pickUpLocationLng=double.parse(dataSnapShot.value["pickup"]["longitude"].toString());
            String pickUpAddress=dataSnapShot.value["pickup_address"].toString();

            double dropOffLocationLat=double.parse(dataSnapShot.value["dropoff"]["latitude"].toString());
            double dropOffLocationLng=double.parse(dataSnapShot.value["dropoff"]["longitude"].toString());
            String dropOffAddress=dataSnapShot.value["dropoff_address"].toString();

            String paymentMethod=dataSnapShot.value['dropoff']["payment_method"].toString();

            String rider_phone=dataSnapShot.value["rider_phone"];


            RideDetails rideDetails=RideDetails();
            rideDetails.ride_request_id=riderequestId;
            rideDetails.pickup_address=pickUpAddress;
            rideDetails.dropoff_address=dropOffAddress;
            rideDetails.dropoff=LatLng(dropOffLocationLat, dropOffLocationLng);
            rideDetails.pickup=LatLng(pickUpLocationLat, pickUpLocationLng);
            rideDetails.payment_method=paymentMethod;
            rideDetails.rider_phone=rider_phone;

            print("Informations :: ");
            print(rideDetails.pickup_address);
            print(rideDetails.dropoff_address);
            
            showDialog(
                context:context ,
                barrierDismissible: false,
                builder:(BuildContext context) =>NotificationDialog(rideDetails: rideDetails,),
            );
          }

    });
  }
}