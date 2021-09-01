import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_landskrona/Models/allUsers.dart';

String mapKey="AIzaSyDUdsbNoHFlUIqAKz2LsAtrPMnGl-MbhW8";

User firebaseUser;

int driverRequestTimeout=40;

String statusRide="";
String rideStatus="Driver Is Coming";

String carDetailsOfDriver="";
String driverName="";
String driverPhone="";

Users userCurrentInfo;

String serverToken= "key=AAAAO3w0SkA:APA91bEdwjVXxl7p-s-2Q8OdDu9tpDAD-j249C0GaM1BjYLIGkWvh18VoxVKYOMUrqPg4nhK5i_D3JauLQKzUQ64_ODhVAsQW6rRf6GVowbL85ly_8w-bpqAN8wY5q-f-W1vWk3qqPO2";