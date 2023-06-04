import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_landskrona/AllScreens/AllWidgets/Divider.dart';
import 'package:taxi_landskrona/AllScreens/AllWidgets/progressDialog.dart';
import 'package:taxi_landskrona/Assistants/requestAssistant.dart';
import 'package:taxi_landskrona/DataHandler/appData.dart';
import 'package:taxi_landskrona/Models/address.dart';
import 'package:taxi_landskrona/Models/placePredictions.dart';
import 'package:taxi_landskrona/configMaps.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionsList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider
            .of<AppData>(context)
            .pickUpLocation
            .placeName ?? "";
    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(color: Colors.black, boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ]),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.0, top: 40.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: Text(
                            "Set Drop Off",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Raleway",
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/location-icon-png-4243.png",
                          height: 16.0,
                          width: 16.0,
                          color: Colors.lightBlueAccent,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  decoration: InputDecoration(
                                    hintText: "Pickup Location",
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11.0, top: 8.0, bottom: 8.0),
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/location-icon-png-4243.png",
                          height: 16.0,
                          width: 16.0,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: TextField(
                                  onChanged: (val) {
                                    findPlace(val);
                                  },
                                  controller: dropOffTextEditingController,
                                  decoration: InputDecoration(
                                    hintText: "Where to go?",
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11.0, top: 8.0, bottom: 8.0),
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            //tile for predictions
            SizedBox(
              height: 10.0,
            ),
            (placePredictionsList.length > 0)
                ? Padding(
              padding:
              EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.separated(
                padding: EdgeInsets.all(0.0),
                itemBuilder: (context, index) {
                  return PredictionTile(
                    placePredictions: placePredictionsList[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    DividerWidget(),
                itemCount: placePredictionsList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890";

      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if (res == "failed") {
        return;
      }
      print("Places Prediction Response :: ");
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionsList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  const PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          getPlaceAddressDetails(placePredictions.place_id, context);
        },
        child: Container(
          child: Column(
            children: [
              SizedBox(
                width: 10.0,
              ),
              Row(
                children: [
                  Icon(Icons.add_location),
                  SizedBox(
                    width: 14.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          (placePredictions.main_text ?? "no primary name"),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          (placePredictions.secondary_text ??
                              "no secondary address"),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                width: 10.0,
              ),
            ],
          ),
        ),
      );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(context: context, builder: (BuildContext context)=>ProgressDialoq(message: "Setting dropoff, please wait!!",));

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Addressforuser address = Addressforuser();

      address.placeName = res["result"]["name"];
      address.placeId = placeId;

      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false).updatedropOffLocationAddress(address);

      print("This is drop off location");
      print(address.placeName);

      Navigator.pop(context,"obtainDirection");
    }
  }
}
