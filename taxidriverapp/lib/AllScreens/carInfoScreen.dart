// @dart=2.9


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taxidriverapp/AllScreens/RegistrationScreen.dart';
import 'package:taxidriverapp/AllScreens/mainscreen.dart';
import 'package:taxidriverapp/configMaps.dart';
import 'package:taxidriverapp/main.dart';

class CarInfoScreen extends StatelessWidget {
  static const String idScreen="carInfo";
  TextEditingController carModelTextEditingController=TextEditingController();
  TextEditingController carNumberTextEditingController=TextEditingController();
  TextEditingController carColorTextEditingController=TextEditingController();


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 22.0,),
              Image.asset("images/taxi_logo.jpeg", width: 390.0, height: 250.0,),
              Padding(padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
              child: Column(
                children: [
                  SizedBox(height: 12.0,),
                  Text("Enter Car Details", style: TextStyle(fontFamily: "Raleway", fontSize: 24.0),),

                  SizedBox(height: 26.0,),
                  TextField(
                    controller: carModelTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Car Model",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0,),
                    ),
                    style: TextStyle(fontSize: 15.0),
                  ),

                  SizedBox(height: 10.0,),
                  TextField(
                    controller: carNumberTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Car Number",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0,),
                    ),
                    style: TextStyle(fontSize: 15.0),
                  ),

                  SizedBox(height: 10.0,),
                  TextField(
                    controller: carColorTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Car Color",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0,),
                    ),
                    style: TextStyle(fontSize: 15.0),
                  ),

                  SizedBox(height: 42.0,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if(carModelTextEditingController.text.isEmpty)
                        {
                          displayToastMessage("Please Write Car Model", context);
                        }
                      else if(carNumberTextEditingController.text.isEmpty)
                      {
                        displayToastMessage("Please Write Car Number", context);
                      }
                      else if(carColorTextEditingController.text.isEmpty)
                      {
                        displayToastMessage("Please Write Car Color", context);
                      }
                     else
                      {
                        saveDriverCarInfo(context);
                      }
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
                          "NEXT",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 26.0,
                        ),
                      ],
                    ),
                  ),
                ),
                  ]),
                  ),

                ],
              ),
              ),

          ),
      );
  }

  void saveDriverCarInfo(context) async
  {
    String userId = (await FirebaseAuth.instance.currentUser).uid;

    Map carInfoMap={
      "car_color": carColorTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text,
    };
    driverRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
  }
}
