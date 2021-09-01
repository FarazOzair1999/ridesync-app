// @dart=2.9
import 'package:flutter/material.dart';
import 'package:taxidriverapp/tabsPages/earningsTabPages.dart';
import 'package:taxidriverapp/tabsPages/homeTabPage.dart';
import 'package:taxidriverapp/tabsPages/profileTabPage.dart';
import 'package:taxidriverapp/tabsPages/ratingTabPage.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainscreen";


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  TabController tabController;
  int selectedIndex=0;


  void onItemClicked(int index)
  {
    setState(() {
      selectedIndex=index;
      tabController.index=selectedIndex;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController=TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          RatingTabPage(),
          EarningTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[

          BottomNavigationBarItem(icon: Icon(Icons.home),
          label: "Home"),
        ],

        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.0),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}

