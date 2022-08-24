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
import 'package:english_words/english_words.dart';


/*
 * Getting Started Page
 */
class PassphraseWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  PassphraseWidget({Key? key,  this.parentScaffoldKey}) : super(key: key);


  @override
  PassphraseState createState() => PassphraseState();
}

class PassphraseState extends State<PassphraseWidget> {

  bool wordGenerated = false;
  List wordList = [];

  void init() {
    super.initState();

  }
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
                  Text("Passphrase".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
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
                    SizedBox(
                      height: config.App(context).appHeight(70),
                      child: Column(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children: [
                          wordGenerated
                          ? Container(
                            width: config.App(context).appWidth(100),
                             child : Column(
                              children: [
                                Text("Your passphrase", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.bold)),
                                SizedBox(height: 20),
                                wordList.length > 0
                                ? SizedBox(

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      SizedBox(
                                        height: config.App(context).appHeight(50),
                                        width: config.App(context).appWidth(30),
                                        child: ListView.separated(
                                          scrollDirection: Axis.vertical,
                                          itemCount: 6,
                                          separatorBuilder: (BuildContext context, int index) => Divider(height: 15, color: Colors.white,),
                                          itemBuilder: (BuildContext context, int index) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text((index + 1).toString() + ". " + wordList[index ].toString(), style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),

                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: config.App(context).appHeight(50),
                                        width: config.App(context).appWidth(30),
                                        child:  ListView.separated(
                                          scrollDirection: Axis.vertical,
                                          itemCount: 6,
                                          separatorBuilder: (BuildContext context, int index) => Divider(height: 15, color: Colors.white,),
                                          itemBuilder: (BuildContext context, int index) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text((index + 7).toString() + ". " + wordList[index + 6 ].toString(), style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                )
                                    : Container(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {

                                      wordGenerated = false;
                                    });

                                  },
                                  child: Container(
                                    width: config.App(context).appWidth(80),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Color(0xff1347b1)
                                    ),
                                    child: Text("Copy passphrase",textAlign:TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            )
                          )
                          : GestureDetector(
                            onTap: () {
                              setState(() {
                                wordList = generateWordPairs().take(12).toList();
                                wordGenerated = true;
                              });

                            },
                            child: Container(
                              width: config.App(context).appWidth(80),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff1347b1)
                              ),
                              child: Text("Generate passphrase",textAlign:TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(
                            width:config.App(context).appWidth(70),
                            child: Text(
                              "We do not store pin codes, passwords or passphrase on your behalf. Forgotten codes can only be reseted by using other login method",
                              textAlign:TextAlign.center, style: TextStyle(color: Color(0xff00264E), fontSize: 17, fontWeight: FontWeight.w400),
                            ),
                          ),

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

}
