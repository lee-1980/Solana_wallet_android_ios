import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utiles/app_config.dart' as config;
import 'package:passcode_screen/passcode_screen.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';



class SplashPage extends StatefulWidget {
  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashPage> {

  final StreamController<bool> _verificationNotifier =
  StreamController<bool>.broadcast();
  bool isAuthenticated = false;


  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  _onPasscodeEntered(String enteredPasscode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPasscode = '1234';
    if(prefs.containsKey("pincode")){
      storedPasscode = prefs.getString("pincode");
    }
    bool isValid = storedPasscode == enteredPasscode;

    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
      Navigator.of(context).pushReplacementNamed('/nav');
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }
  _resetAppPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      print(result);
      // Navigator.maybePop(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.transparent,
        body:  Stack(
          children: [
            Container(
              width: config.App(context).appWidth(100),
              height: config.App(context).appHeight(100),
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
            Padding(
                padding: EdgeInsets.only(top: config.App(context).appWidth(15), left: 30, right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   child: Image.asset('assets/img/icon_arrow_forward.png', color: Colors.white,),
                    // ),
                    Text("Pin Code", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400)),
                    // SizedBox(width: 20,),
                  ],
                )
            ),

            Padding(
              padding: EdgeInsets.only(top: config.App(context).appWidth(40)),
              child:   Container(
                width: config.App(context).appWidth(100),
                decoration: BoxDecoration(
                    color: Colors.white
                ),

              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: config.App(context).appWidth(40)),
              // child:  Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text("Enter your passcode", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
              //   ],
              // )
              child: ListView(
                children: [
                  SizedBox(
                    width: config.App(context).appWidth(100),
                    height: config.App(context).appWidth(150),
                    child: PasscodeScreen(
                        title: Text(
                          'Enter your passcode',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff00264E), fontSize: 28),
                        ),
                        circleUIConfig: CircleUIConfig(
                            borderColor: Color(0xff00264E),
                            fillColor: Color(0xff00264E),
                            circleSize: 30),
                        keyboardUIConfig: KeyboardUIConfig(
                            digitTextStyle: TextStyle(color: Color(0xff00264E), fontSize: 34, fontWeight: FontWeight.w700),
                            digitBorderWidth: 2, primaryColor: Color(0xff00264E)),
                        cancelButton: Icon(
                          Icons.arrow_back,
                          color: Color(0xff00264E),
                        ),
                        digits: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
                        deleteButton: Text(
                          'Cancel',
                          style: const TextStyle(fontSize: 16, color: Color(0xff00264E)),
                          semanticsLabel: 'Delete',
                        ),
                        passwordEnteredCallback: _onPasscodeEntered,
                        shouldTriggerVerification: _verificationNotifier.stream,
                        backgroundColor: Colors.white,
                        cancelCallback: _onPasscodeCancelled,
                        passwordDigits: 4,
                        bottomWidget: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                            child: TextButton(
                              child: Text(
                                "Reset passcode",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff00264E),
                                    fontWeight: FontWeight.w300),
                              ),
                              onPressed: _resetAppPassword,
                              // splashColor: Colors.white.withOpacity(0.4),
                              // highlightColor: Colors.white.withOpacity(0.2),
                              // ),
                            ),
                          ),
                        )
                    ),
                  )
                ],
              ),
            ),

          ],
        )
    );
  }




}
