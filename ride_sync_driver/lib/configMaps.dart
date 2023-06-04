// @dart=2.9

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxidriverapp/Models/allUsers.dart';
import 'package:taxidriverapp/Models/drivers.dart';

String mapKey="AIzaSyDUdsbNoHFlUIqAKz2LsAtrPMnGl-MbhW8";

User firebaseUser;

Users userCurrentInfo;

User currentFirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;

StreamSubscription<Position> rideStreamSubscription;

Position currentPosition;

Drivers driversInformation;