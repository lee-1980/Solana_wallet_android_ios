import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:fyfypay/pages/pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';


/*
 * Getting Started Page
 */
class PayWidget extends StatefulWidget {
  PayWidget({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  PayState createState() => PayState(this.store);
}

class PayState extends State<PayWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  StateWrapper store;
  late String address;
  late String networkURL;
  QRViewController? qrController;
  Barcode? result;
  bool scanStarted = true;
  String barcodeResult = "";

  bool isLoading = false;
  TextEditingController commentController = new TextEditingController();
  late  String selectedWalletAddress = "";
  late  int selectedWalletIndex = 0;
  double amountValue = 0.00;

  PayState(this.store);

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
            Padding(
                padding:EdgeInsets.only(top: config.App(context).appWidth(10)),
                child: scanStarted ? qrScanView()
                    : Padding(
                  padding: EdgeInsets.only(top: config.App(context).appWidth(30)),
                  child:  ListView(
                    children: [
                      Column(
                        children: [
                          Text("Send money", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(amountValue.toString(), style: TextStyle(color: Color(0xff00264E), fontSize: 60, fontWeight: FontWeight.bold)),
                              Text("\$", style: TextStyle(color: Color(0xff00264E), fontSize: 40,)),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Icon(CupertinoIcons.arrow_down, size: 36, color: Color(0xff00264E),),
                          SizedBox(height: 20,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(address, textAlign: TextAlign.center, style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600)),
                          ),
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
                                SizedBox(
                                  width: config.App(context).appWidth(70),
                                  child:  TextFormField(
                                    controller: commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Comment',
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // child: Text("28v5kipdi...sdewDoS43", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                                ),

                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Choose Wallet", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                          SizedBox(height: 10,),
                          Container(
                              width: config.App(context).appWidth(80),
                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xff00264E)
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset('assets/img/icon_wallet.png',color: Color(0xff00264E)),
                                      SizedBox(
                                        width: config.App(context).appWidth(70),
                                        child: DropdownButton<String>(
                                          underline: SizedBox(),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Color(0xff00264E)),
                                          icon: Icon(Icons.arrow_forward_ios_rounded , color: Color(0xff00264E),),
                                          items: store.state.accounts.entries.map((wallet) {
                                            return DropdownMenuItem<String>(
                                                value: wallet.key,
                                                child: SizedBox(
                                                  width: config.App(context).appWidth(70),
                                                  child : Text(wallet.value.address, style: TextStyle(color: Color(0xff00264E)),),
                                                )
                                            );
                                          }).toList(),
                                          // value:   selectedWalletAddress,
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              this.selectedWalletAddress = store.state.accounts[value]!.address;
                                              var temp = value!.trim().split(' ');
                                              print(temp.sublist(1).join(' ').trim());
                                              this.selectedWalletIndex = int.parse(temp.sublist(1).join(' ').trim());
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: config.App(context).appWidth(60),
                                          height: 50,
                                          child: Center(
                                            child: Text(selectedWalletAddress, overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: Color(0xff00264E), fontSize: 14, fontWeight: FontWeight.w400)),
                                          )
                                      )
                                    ],
                                  )
                                ],
                              )
                          ),

                          SizedBox(height: 40,),
                          SlidableButton(
                            height: 50,
                            width: config.App(context).appWidth(80),
                            buttonWidth: config.App(context).appWidth(20),
                            color: Colors.white,
                            // buttonColor: Color(0xff0049b0),
                            dismissible: false,
                            initialPosition: SlidableButtonPosition.left,
                            label: Container(
                              height: 70,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Color(0xff0049b0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Pay", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20.0,
                                    semanticLabel: 'Text to announce in accessibility modes',
                                  )
                                ],
                              ),
                            ),
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xff6491cf)
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Swipe to confirm", textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: Color(0xff2f4556),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (position) {
                              setState(() {
                                if (position == SlidableButtonPosition.right) {
                                  print("Button is on the right");
                                  sendUSDC();
                                } else {
                                  print("Button is on the left");

                                }
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )
            ),

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
                  Text("Pay".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(width: 10,)
                ],
              ),
            ),


          ],
        )
    );
  }

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );


  Widget qrScanView() {
    return Container(
        width: config.App(context).appWidth(100),
        height: config.App(context).appHeight(100),
        child:  Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
            Image.asset('assets/img/qr_back.png', width: config.App(context).appWidth(100), fit: BoxFit.fitWidth,),
            Padding(
                padding: EdgeInsets.only(top: config.App(context).appWidth(35)),
                child: SizedBox(
                  width: config.App(context).appWidth(100),
                  child: Text("Scan QR-Code", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                )
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      scanStarted = false;
                    });
                  },
                  child: Container(
                    width: config.App(context).appWidth(60),
                    margin: EdgeInsets.only(bottom: 100),
                    child: Text("[Auto transaction to next when scanned, click here see]",
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
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
        String resultTemp = scanData.code.toString();
        var parts = resultTemp.split(':');
        parts[0].trim();
        var body = parts.sublist(1).join(':').trim();
        var secondPart = body.split('?');
        var thirdPart = body.split(':');
        secondPart[1].trim();
        print(thirdPart.sublist(1)[0]);
        barcodeResult = secondPart.sublist(0)[0].toString();
        address = barcodeResult;
        amountValue = double.parse(thirdPart.sublist(1)[0])/100;
        scanStarted = false;
      });
    });
  }

  void sendUSDC() {
    var commentValue = commentController.text.trim();
    if(commentValue == "") {
      Fluttertoast.showToast(
          msg: "Input the comment text.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } else {
      setState(() {
        isLoading = true;
      });
      store.state.sendUSDCToken(address,amountValue,  selectedWalletIndex).then((value) => {
        if(value) {
          Fluttertoast.showToast(
              msg: "Sent Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          ),
          setState(() {
            scanStarted = false;
            isLoading = false;
            address = "";
            commentValue = "";
          })
        } else {
          Fluttertoast.showToast(
              msg: "Send failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          )
        },
        setState(() {
          isLoading = false;
        })
      });
    }

  }

}
