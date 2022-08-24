import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';


/*
 * Getting Started Page
 */
class MainHomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  MainHomeWidget({ Key? key,  this.parentScaffoldKey}) : super(key: key);
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainHomeWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        key: widget.key,
        // resizeToAvoidBottomPadding: false,
        body:  Stack(
          children: [
            Container(
              width: config.App(context).appWidth(100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      const Color(0xff001B30),
                      const Color(0xff003271),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Image.asset('assets/img/fyfy_pay_logo.png'),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: config.App(context).appHeight(37),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pushNamed('/Receive')
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(5)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(1) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 2, color: Colors.white
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 30,),
                              Text(
                                "Receive".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Image.asset('assets/img/icon_receive_1.png')

                            ],
                          )
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pushNamed('/Send')
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(5)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(1) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 2, color: Colors.white
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 30,),
                              Text(
                                "Send".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Image.asset('assets/img/icon_send_1.png')

                            ],
                          )
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pushNamed('/Pay')
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(5)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(1) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 2, color: Colors.white
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 30,),
                              Text(
                                "Pay".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Image.asset('assets/img/icon_qr.png')

                            ],
                          )
                      ),
                    ),
                  ],
                ),
              )
            )
          ],
        )
    );
  }

}
