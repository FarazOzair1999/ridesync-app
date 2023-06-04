// @dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taxidriverapp/AllScreens/AllWidgets/progressDialog.dart';
import 'package:taxidriverapp/AllScreens/RegistrationScreen.dart';
import 'package:taxidriverapp/AllScreens/mainscreen.dart';
import 'package:taxidriverapp/configMaps.dart';
import 'package:taxidriverapp/main.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 80.0,
              ),
              Image(
                image: AssetImage('images/taxi_logo.jpeg'),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                "Login as Driver",
                style: TextStyle(fontSize: 24.0, fontFamily: "Raleway"),
                textAlign: TextAlign.center,
              ),
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 1.0,
                      ),
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black, // background
                          onPrimary: Colors.white, // foreground
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0),
                          ),
                        ),
                        onPressed: () {
                          print(" Login Button pressed");
                          if(!emailTextEditingController.text.contains("@"))
                          {
                          displayToastMessage("Email address is not valid (does not contain @)", context);
                          }
                          else if (passwordTextEditingController.text.length<7)
                          {
                            displayToastMessage("Password must be at least 7 characters", context);
                          }
                          else if (passwordTextEditingController.text.isEmpty)
                            {
                              displayToastMessage("Password is mandatrory", context);
                            }
                          else {
                            loginAndAuthenticateUser(context);
                          }
                        },
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Raleway"),
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
              TextButton(
                  onPressed: () {
                    print("Do not have an account button pressed");
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationScreen.idScreen, (route) => false);
                  },
                  child: Text("Do not have an Account? Register Here!"))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {

    showDialog(context: context, builder: (BuildContext context)
    {
      return ProgressDialoq(message: "Authenticating please wait...",);
    },
    barrierDismissible: false
    );
    final User userCredential = (await _firebaseAuth.signInWithEmailAndPassword(
            email: emailTextEditingController.text,
            password: passwordTextEditingController.text
    ).catchError((errMsg){
      Navigator.pop(context);
      displayToastMessage(errMsg.toString(), context);
    })).user;

    if (userCredential != null) {
      driverRef
          .child(userCredential.uid)
          .once()
          .then((DataSnapshot snap) {
                if (snap.value != null) {
                  currentFirebaseUser=userCredential;
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainScreen.idScreen, (route) => false);
                  displayToastMessage("Welcome back! You are logged in" , context);
                }
                else {
                  Navigator.pop(context);
                  _firebaseAuth.signOut();
                  displayToastMessage("No such account exists for this user, please create a new account", context);
                }
              });
          }
    else{
      Navigator.pop(context);
      displayToastMessage("Error occured, not signed in", context);
    }
  }
}
