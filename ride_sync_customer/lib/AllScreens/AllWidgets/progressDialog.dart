import 'package:flutter/material.dart';

class  ProgressDialoq extends StatelessWidget {

  String message;
  ProgressDialoq({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
    backgroundColor: Colors.black,
    child: Container(
      margin: EdgeInsets.all(15.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color:Colors.black,
        borderRadius: BorderRadius.circular(6.0),

      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            SizedBox(width: 6.0,),
            CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.white),),
            SizedBox(width: 26.0,),
            Text(
                message,
                style: TextStyle(color:Colors.white, fontSize: 10.0),
            )
          ],
        ),
      ),
    ),
    );
  }
}
