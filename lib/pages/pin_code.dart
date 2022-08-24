import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:fyfypay/pages/pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';


/*
 * Getting Started Page
 */
class PinCodeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  PinCodeWidget({Key? key,  this.parentScaffoldKey}) : super(key: key);


  @override
  PinCodeeState createState() => PinCodeeState();
}

class PinCodeeState extends State<PinCodeWidget> {

  TextEditingController newPinCode = new TextEditingController();
  TextEditingController repeatPinCode = new TextEditingController();
  GlobalKey<FormState> pinCodeForm  = new GlobalKey<FormState>();

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Import wallet')),
        backgroundColor: Colors.white,
        key: widget.parentScaffoldKey,
        body: Stack(
          children: [
            Container(
              width: config.App(context).appWidth(100),
              height: config.App(context).appHeight(15),
              padding: EdgeInsets.symmetric(horizontal: 30),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset('assets/img/icon_arrow_backward.png'),
                  ),
                  Text("Pin Code".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(width: 10,)
                ],
              ),
            ),
            Padding(
              padding:EdgeInsets.only(top: config.App(context).appWidth(40)),
              child: SizedBox(
                width: config.App(context).appWidth(100),
                child: ListView(
                  children: [
                    Form(
                      key: pinCodeForm,
                      child: Column(
                        children: [
                          Text("Set pin code", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 20,),
                          Text("New pin code", style: TextStyle(color: Color(0xff00264E), fontSize: 20, fontWeight: FontWeight.w400)),
                          SizedBox(height: 20,),
                          Container(
                            width: config.App(context).appWidth(80),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: Color(0xff00264E)
                                ),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: SizedBox(
                              width: config.App(context).appWidth(50),
                              child:  TextFormField(
                                controller: newPinCode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Empty code';
                                  } else if (value.length > 4) {
                                    return 'Pin code length is not correct';
                                  }
                                },
                                style: TextStyle(color: Color(0xff00264E), fontSize: 18 ),
                                decoration: const InputDecoration(
                                  hintText: '',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                onChanged: (String value) async {

                                },
                              ),
                              // child: Text("28v5kipdi...sdewDoS43", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                            ),
                          ),
                          SizedBox(height: 40,),
                          Text("Repeat pin code", style: TextStyle(color: Color(0xff00264E), fontSize: 20, fontWeight: FontWeight.w400)),
                          SizedBox(height: 20,),
                          Container(
                            width: config.App(context).appWidth(80),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: Color(0xff00264E)
                                ),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: SizedBox(
                              width: config.App(context).appWidth(50),
                              child:  TextFormField(
                                controller: repeatPinCode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Empty code';
                                  } else if (value.length > 4) {
                                    return 'Pin code length is not correct';
                                  }
                                },
                                style: TextStyle(color: Color(0xff00264E), fontSize: 18 ),
                                decoration: const InputDecoration(
                                  hintText: '',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                onChanged: (String value) async {

                                },
                              ),
                              // child: Text("28v5kipdi...sdewDoS43", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                            ),
                          ),
                          SizedBox(height: 60,),
                          GestureDetector(
                            onTap: () {
                              changePinCode();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff1347b1)
                              ),
                              child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(height: 100,),
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

                  ],
                )
              )
            )
          ],
        )
    );
  }

  Future<void> changePinCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var newPin = newPinCode.text.toString();
    var repeatPin = repeatPinCode.text.toString();
    if(pinCodeForm.currentState!.validate()) {
      if(newPin == repeatPin) {
        print(newPin);
        prefs.setString("pincode", newPin);
        Fluttertoast.showToast(
            msg: "Pin code saved.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
            msg: "Incorrect pin code",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

}
