import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:taxi_landskrona/Models/address.dart';

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