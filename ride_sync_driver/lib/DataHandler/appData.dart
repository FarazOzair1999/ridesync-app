// @dart=2.9

import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:taxidriverapp/Models/address.dart';

class AppData extends ChangeNotifier
{
  Addressforuser pickUpLocation,dropOffLocation;
  void updatePickUpLocationAddress(Addressforuser pickUpAddress)
  {
    pickUpLocation=pickUpAddress;
    notifyListeners();
  }
  void updatedropOffLocationAddress(Addressforuser dropOffAddress)
  {
    dropOffLocation=dropOffAddress;
    notifyListeners();
  }

}