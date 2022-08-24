import 'package:fyfypay/pages/main_home.dart';
import 'package:fyfypay/pages/settings.dart';
import 'package:fyfypay/pages/my_wallet.dart';
import 'package:fyfypay/state/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../utiles/app_config.dart' as config;


// ignore: must_be_immutable
class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final StateWrapper store;
  Widget currentPage = MainHomeWidget();
  PagesWidget({
     Key? key,
    this.currentTab,
    required this.store
  }) {
    currentTab = 0;
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {


  Color defaultColor = Color(0xff5e7392);
  Color activeColor = Color(0xff010f1a);
  initState() {
    super.initState();
    _selectTab(widget.currentTab);

  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = MainHomeWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage = WatchAddress(store: widget.store);
          break;
        case 2:
          widget.currentPage = SettingsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: config.App(context).onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xff003271),
        key: widget.scaffoldKey,
        body: Stack(
          children: [
            widget.currentPage,
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: defaultColor,
                    currentIndex: widget.currentTab,
                    backgroundColor: Colors.white,
                    onTap: (int i) {
                      this._selectTab(i);
                    },
                    // this will be set when a new tab is tapped
                    items: <BottomNavigationBarItem> [
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/img/icon_home_bottom.png',height: config.App(context).appWidth(6), fit: BoxFit.fitHeight, color: widget.currentTab == 0 ? activeColor : defaultColor,),
                        title: Container(
                          margin: EdgeInsets.only(top: 5),
                          child:  Text("Home", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: widget.currentTab == 0 ? activeColor : defaultColor,),),
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/img/icon_wallet_bottom.png',height: config.App(context).appWidth(6), fit: BoxFit.fitHeight, color: widget.currentTab == 1 ? activeColor : defaultColor,),
                        title: Container(
                          margin: EdgeInsets.only(top: 5),
                          child:  Text("My wallet", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: widget.currentTab == 1 ? activeColor : defaultColor,),),
                        ),
                      ),

                      BottomNavigationBarItem(
                        icon: Image.asset('assets/img/icon_settings_bottom.png', height: config.App(context).appWidth(6), fit: BoxFit.fitHeight, color: widget.currentTab == 2 ? activeColor : defaultColor,),
                        title: Container(
                          margin: EdgeInsets.only(top: 5),
                          child:  Text("Settings", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: widget.currentTab == 2 ? activeColor : defaultColor,),),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            )
          ],
        )
        // bottomNavigationBar:

      ),
    );
  }
}
