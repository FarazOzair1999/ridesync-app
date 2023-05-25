import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_landskrona/AllScreens/LoginScreen.dart';
import 'package:taxi_landskrona/AllScreens/RegistrationScreen.dart';
import 'package:taxi_landskrona/AllScreens/mainscreen.dart';
import 'package:taxi_landskrona/DataHandler/appData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child("drivers");

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  // void initState() {
  //   super.initState();
  //   initSecurityState();
  // }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Landskrona',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Raleway",
          primaryColor: Colors.black,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idScreen
            : MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
        },
      ),
    );
  }
}
