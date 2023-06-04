// @dart=2.9
import 'package:flutter/material.dart';
import 'package:taxidriverapp/Assistants/assistantMethods.dart';


class CollectFareDialog extends StatelessWidget {

  final String paymentMethod;
  final double fareAmount;

  CollectFareDialog({this.paymentMethod, this.fareAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
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
            SizedBox(height: 22.0,),
            
            Text("Trip Fare",style: TextStyle(fontSize: 20.0,color: Colors.white),),

            SizedBox(height: 22.0,),

            Divider(),
            SizedBox(height: 16.0,),

            Text("\$$fareAmount",style: TextStyle(fontSize: 20.0,color: Colors.white),),

            SizedBox(height: 16.0,),

            Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background
                  onPrimary: Colors.white, // foreground
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  AssistantMethods.enablehomeTabLocationLiveUpdates();
                },
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Collect Cash",
                        style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.attach_money, color: Colors.white, size: 26.0,),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }
}
