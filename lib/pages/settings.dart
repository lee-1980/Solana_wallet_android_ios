import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:fyfypay/pages/pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';


/*
 * Getting Started Page
 */
class SettingsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  SettingsWidget({ Key? key,  this.parentScaffoldKey}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late String address;
  late String networkURL;
  QRViewController? qrController;
  Barcode? result;
  late String text = "";
  bool securitySet = false;
  int methodNumber = 0;

  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Import wallet')),
        backgroundColor: Colors.white,
        key: scaffoldKey,
        body: Stack(
          children: [
            Container(
              width: config.App(context).appWidth(100),
              height: config.App(context).appHeight(15),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Settings".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding:EdgeInsets.only(top: config.App(context).appWidth(40)),
              child: securitySet ? SizedBox(
                width: config.App(context).appWidth(100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Application login method".toUpperCase(), style: TextStyle(color: Color(0xff00264E), fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 30,),
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          methodNumber = 0;
                        }),
                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.of(context).pushNamed('/PinCode');
                        })

                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(3)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(5) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 1, color: Color(0xff00264E)
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: config.App(context).appWidth(8),
                                    height: config.App(context).appWidth(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(
                                            color: Color(0xff00264E), width: 1
                                        )
                                    ),
                                    child: Center(
                                      child: methodNumber == 0
                                          ? Icon(CupertinoIcons.app_fill, color: Colors.green, size: config.App(context).appWidth(6),)
                                          : Container()
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    "Pin code", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Icon(CupertinoIcons.right_chevron, color: Colors.black87,)

                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          methodNumber = 1;
                        }),
                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.of(context).pushNamed('/Password');
                        })
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(3)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(5) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 1, color: Color(0xff00264E)
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: config.App(context).appWidth(8),
                                    height: config.App(context).appWidth(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(
                                            color: Color(0xff00264E), width: 1
                                        )
                                    ),
                                    child: Center(
                                        child: methodNumber == 1
                                            ? Icon(CupertinoIcons.app_fill, color: Colors.green, size: config.App(context).appWidth(6),)
                                            : Container()
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    "Password", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Icon(CupertinoIcons.right_chevron, color: Colors.black87,)

                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          methodNumber = 2;
                        }),
                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.of(context).pushNamed('/Passphrase');
                        })
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(3)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(5) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 1, color: Color(0xff00264E)
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: config.App(context).appWidth(8),
                                    height: config.App(context).appWidth(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(
                                            color: Color(0xff00264E), width: 1
                                        )
                                    ),
                                    child: Center(
                                        child: methodNumber == 2
                                            ? Icon(CupertinoIcons.app_fill, color: Colors.green, size: config.App(context).appWidth(6),)
                                            : Container()
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    "Passphrase", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Icon(CupertinoIcons.right_chevron, color: Colors.black87,)

                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 200,),
                    SizedBox(
                      width:config.App(context).appWidth(70),
                      child: Text(
                        "We do not store pin codes, passwords or passphrase on your behalf. Forgotten codes can only be reseted by using other login method",
                        textAlign:TextAlign.center, style: TextStyle(color: Color(0xff00264E), fontSize: 17, fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
              )
              :SizedBox(
                width: config.App(context).appWidth(100),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          securitySet = true;
                        })
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(5)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(5) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 2, color: Color(0xff00264E)
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Security Settings", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Icon(CupertinoIcons.right_chevron, color: Colors.black87,)

                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false)
                      },
                      child:  Container(
                          width: config.App(context).appWidth(80),
                          height: config.App(context).appWidth(13),
                          margin: EdgeInsets.only(bottom: config.App(context).appWidth(5)),
                          padding: EdgeInsets.symmetric(horizontal:config.App(context).appWidth(5) ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 2, color: Color(0xff00264E)
                              )
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Log Out", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Icon(CupertinoIcons.right_chevron, color: Colors.black87,)

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
