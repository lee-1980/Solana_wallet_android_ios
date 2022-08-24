import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:fyfypay/pages/pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';


/*
 * Getting Started Page
 */
class ReceiveWidget extends StatefulWidget {
  ReceiveWidget({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  ReceiveState createState() => ReceiveState(this.store);
}

class ReceiveState extends State<ReceiveWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  StateWrapper store;
  late String address;
  late String networkURL;
  QRViewController? qrController;
  Barcode? result;

  late GlobalKey globalKey = new GlobalKey();
  late String _dataString = "Hello from this QR";
  late String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();

  ReceiveState(this.store);

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PagesWidget(currentTab: 0, store: store,)));
                    },
                    child: Image.asset('assets/img/icon_arrow_backward.png'),
                  ),
                  Text("My Wallet".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
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
                    Column(
                      children: [
                        Text("Wallet Address", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                // onTap: _onQRViewCreated(qrController),
                                onTap: () {
                                  if (_textController.text.isEmpty) {
                                    setState(() {
                                      _dataString = "";
                                    });
                                  } else {
                                    setState(() {
                                      _dataString = _textController.text;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Color(0xff00264E)
                                  ),
                                  child: Image.asset('assets/img/icon_copy.png'),
                                ),
                              ),

                              SizedBox(
                                width: config.App(context).appWidth(60),
                                child:  TextFormField(
                                  controller: _textController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Empty address';
                                    } else if (value.length < 43 || value.length > 50) {
                                      return 'Address length is not correct';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '28v5kipdi...sdewDoS43',
                                  ),
                                  onChanged: (String value) async {
                                    print(value);
                                    address = value;
                                  },
                                ),
                                // child: Text("28v5kipdi...sdewDoS43", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                              ),


                            ],
                          ),
                        ),
                        SizedBox(height: 40,),
                        Text("QR Code", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
                        SizedBox(height: 40,),
                        Container(
                          color: Colors.white,
                          child:RepaintBoundary(
                            key: globalKey,
                            child: QrImage(
                              data: _dataString,
                              size: config.App(context).appWidth(60),
                            ),
                          ),
                        ),
                        // Image.asset('assets/img/qr_value.png', width: config.App(context).appWidth(60), fit: BoxFit.fitWidth,)

                      ],
                    ),
                  ],
                )
              )
            )

          ],
        )
    );
  }

  void addAccount() async {
    // Create the account
    store.createWatcher(address).then((_) {
      // Go to Home page
      // Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  // Future<void> _captureAndSharePng() async {
  //   try {
  //     RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
  //     var image = await boundary.toImage();
  //     ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
  //     Uint8List pngBytes = byteData.buffer.asUint8List();
  //     final tempDir = await getTemporaryDirectory();
  //     final file = await new File('${tempDir.path}/image.png').create();
  //     await file.writeAsBytes(pngBytes);
  //     final channel = const MethodChannel('channel:me.alfian.share/share');
  //     channel.invokeMethod('shareFile', 'image.png');
  //   } catch(e) {
  //     print(e.toString());
  //   }
  // }



}
