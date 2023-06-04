// @dart=2.9

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:taxidriverapp/AllScreens/RegistrationScreen.dart';
import 'package:taxidriverapp/AllScreens/newRideScreen.dart';
import 'package:taxidriverapp/Assistants/assistantMethods.dart';

import 'package:taxidriverapp/Models/rideDetails.dart';
import 'package:taxidriverapp/main.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;

  NotificationDialog({this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30.0,
            ),
            Image.asset(
              "images/service-car-icon-png-2414.png",
              width: 120.0,
              color: Colors.blue,
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              "New Ride Request",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/location-icon-png-4243.png",
                        height: 16.0,
                        width: 16.0,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Container(
                            child: Text(
                                "Pickup Location: ${rideDetails.pickup_address}",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white))),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/location-icon-png-4243.png",
                        height: 16.0,
                        width: 16.0,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Container(
                            child: Text(
                                "DropOff Location: ${rideDetails.dropoff_address}",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white))),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              height: 2.0,
              color: Colors.white,
              thickness: 2.0,
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                      onPrimary: Colors.white, // foreground
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                    ),
                    onPressed: () {
                      print(" Cancel Button pressed");
                      FlutterRingtonePlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Cancel".toUpperCase(),
                          style:
                              TextStyle(fontSize: 14.0, fontFamily: "Raleway"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // background
                      onPrimary: Colors.white, // foreground
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                    ),
                    onPressed: () {
                      FlutterRingtonePlayer.stop();
                      checkAvailabilityOfRide(context);
                    },
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Accept".toUpperCase(),
                          style:
                              TextStyle(fontSize: 14.0, fontFamily: "Raleway"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestRef.once().then((DataSnapshot dataSnapShot) {
      Navigator.pop(context);
      String RideId = "";
      if (dataSnapShot.value != null) {
        RideId = dataSnapShot.value.toString();
      } else {
        displayToastMessage("Ride not exists", context);
      }

      if (RideId == rideDetails.ride_request_id) {
        rideRequestRef.set("accepted");
        AssistantMethods.disablehomeTabLocationLiveUpdates();
        Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRideScreen(rideDetails:rideDetails)));
      } else if (RideId == "cancelled") {
        displayToastMessage("Ride has been Cancelled", context);
      } else if (RideId == "timeout") {
        displayToastMessage("Ride has timed out", context);
      } else {
        displayToastMessage("Ride not exists", context);
      }
    });
  }
}
