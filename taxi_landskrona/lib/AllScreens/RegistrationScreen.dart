import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taxi_landskrona/AllScreens/AllWidgets/progressDialog.dart';
import 'package:taxi_landskrona/AllScreens/LoginScreen.dart';
import 'package:taxi_landskrona/AllScreens/mainscreen.dart';
import 'package:taxi_landskrona/main.dart';

class RegistrationScreen extends StatelessWidget {

  static const String idScreen = "register";
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
              SizedBox(height: 40.0,),
              Image(
                image: AssetImage('images/taxi_logo.jpeg'),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1.0,),
              Text(
                "Register as User",
                style: TextStyle(fontSize: 24.0, fontFamily: "Raleway"),
                textAlign: TextAlign.center,
              ),

              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Email Address",
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 1.0,),
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
                            )
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 40.0,),
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
                          if(nameTextEditingController.text.length < 4)
                            {
                              displayToastMessage("name must be at least 4 characters", context);
                            }
                          else if(!emailTextEditingController.text.contains("@"))
                            {
                              displayToastMessage("Email address is not valid (does not contain @)", context);
                            }
                          else if (phoneTextEditingController.text.isEmpty)
                            {
                              displayToastMessage("Phone number is necessary", context);
                            }
                          else if (passwordTextEditingController.text.length<7)
                            {
                              displayToastMessage("Password must be at least 7 characters", context);
                            }
                          else{
                            registerNewUser(context);
                          }

                        },
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Create an Account",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Raleway"),
                            ),
                          ),
                        ),


                      )
                    ],
                  )
              ),

              TextButton(onPressed: () {
                print("Already have an account button pressed");
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
                  child: Text("Already have an account? Login Here!")
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async
  {
    showDialog(context: context, builder: (BuildContext context)
    {
      return ProgressDialoq(message: "Registering please wait...",);
    },
        barrierDismissible: false
    );
    try {
      final User userCredential = (await _firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text
      )).user;
      if (userCredential != null){

        Map userDataMap={
          "name": nameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
        };
        userRef.child(userCredential.uid).set(userDataMap);
        displayToastMessage("Congratulations! your account has been created", context);
        Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
      }
      else{
        Navigator.pop(context);
        displayToastMessage("User not created", context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        displayToastMessage("The account already exists for this email", context);
      }

    } catch (e) {
      print(e);
      displayToastMessage(e.toString(), context);
    }


  }
}
displayToastMessage(String message,BuildContext context){
  Fluttertoast.showToast(msg: message);
}
