import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:fyfypay/pages/pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solana/solana.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:slidable_button/slidable_button.dart';

/*
 * Getting Started Page
 */
class SendWidget extends StatefulWidget {
  SendWidget({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  SendState createState() => SendState(this.store);
}

class SendState extends State<SendWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  StateWrapper store;
  late String address;
  late String networkURL;
  QRViewController? qrController;
  Barcode? result;
  late String text = "";
  late  String selectedWalletAddress = "";
  late  int selectedWalletIndex = 0;

  bool isSetAmount = false;
  bool scanStarted = false;
  bool isLoading = false;
  bool isSendConfirmation = false;
  String barcodeResult = "";
  TextEditingController commentController = new TextEditingController();
  SendState(this.store);


  void initState() {
    super.initState();
    address = "";
  }

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
            scanStarted
            ? qrScanView()
            : Padding(
              padding:EdgeInsets.only(top: config.App(context).appWidth(40)),
              child: isSendConfirmation
              ?  confirmationPage()
              :SizedBox(
                width: config.App(context).appWidth(100),
                child: isSetAmount
                ? sendDetailBox()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("Enter Amount", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(text != null ? text : "100", style: TextStyle(color: Color(0xff00264E), fontSize: 60, fontWeight: FontWeight.bold)),
                            Text("\$", style: TextStyle(color: Color(0xff00264E), fontSize: 40,)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        NumericKeyboard(
                          onKeyboardTap: _onKeyboardTap,
                          textColor: Color(0xff00264E),
                          rightIcon: Icon(CupertinoIcons.dot_square_fill, size: 32, color: Color(0xff00264E),),
                          rightButtonFn: () {
                            setState(() {
                              if(text.length > 0) {
                                text = text + ".";
                              }

                            });
                          },
                          leftIcon: Icon(Icons.backspace, color: Color(0xff00264E),),
                          leftButtonFn: () {
                            setState(() {
                              if(text.length > 0) {
                                text = text.substring(0, text.length - 1);
                              }

                            });
                          },
                          // leftIcon: Icon(Icons.check, color: Color(0xff00264E),),
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly
                        ),
                        GestureDetector(
                          onTap: () {
                            if(text.length != 0) {
                              print(text);
                              if(double.parse(text) > 0 ) {
                                setState(() {
                                  isSetAmount = true;
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Amount should be bigger than 0.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Insert the Amount.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }
                          },
                          child: Container(
                              width: config.App(context).appWidth(20),
                              margin: EdgeInsets.only(bottom:  10, left: config.App(context).appWidth(35)),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5), color: Color(0xff0049b0)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Next", textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                  SizedBox(width: 10),
                                  Icon(CupertinoIcons.arrow_right, size: 18, color: Colors.white,)
                                ],
                              )
                          ),
                        )
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
                  Text("Send".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(width: 10,)
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget sendDetailBox() {
    return Column(
      children: [
        Text("Send To", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
        SizedBox(height: 20,),
        Container(
          width: config.App(context).appWidth(80),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1, color: Color(0xff00264E)
              ),
              borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/img/icon_wallet_bottom.png'),
              SizedBox(width: 20,),

              SizedBox(
                width: config.App(context).appWidth(60),
                child:  TextFormField(
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
                    hintText: 'Enter Address manually',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (String value) async {
                    print(value);
                    address = value;
                  },
                  initialValue: (barcodeResult != null) ? barcodeResult : "",
                ),
                // child: Text("28v5kipdi...sdewDoS43", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
              ),


            ],
          ),
        ),
        SizedBox(height: 20,),
        Text("Or", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 20,),
        GestureDetector(
          onTap: () {
            setState(() {
              scanStarted = true;
            });
          },
          child: Container(
            width: config.App(context).appWidth(80),
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: Color(0xff00264E)
                ),
                borderRadius: BorderRadius.circular(5)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/icon_qr_code.png', color: Color(0xff00264E),),
                SizedBox(width: 30,),
                Text("Scan QR-Code", style: TextStyle(color: Color(0xff00264E), fontSize: 22, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        SizedBox(height: 40,),
        Text("Saved Wallets", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
        Expanded(
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    width: config.App(context).appWidth(70),
                    margin: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(15)),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: store.state.accounts.length,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 2, color: Color(0xff081B2A)
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.7)
                                ),
                                child: Text(
                                  "A"+ index.toString(), style: TextStyle(color: Color(0xff081B2A), fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                store.state.accounts["Account "+ index.toString()]!.name, style: TextStyle(color: Color(0xff081B2A), fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: config.App(context).appWidth(60),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: Color(0xffe8e8e8)
                    ),
                    child: Text("Show all saved wallets", textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 40,),
                  Row(  mainAxisAlignment : MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(address == "") {
                            Fluttertoast.showToast(
                                msg: "Input the target address.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          } else {
                            setState(() {
                              isSendConfirmation = true;
                            });
                          }

                        },
                        child: Container(
                            width: config.App(context).appWidth(20),
                            margin: EdgeInsets.only(right:  config.App(context).appWidth(10)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5), color: Color(0xff0049b0)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Next", textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                SizedBox(width: 10),
                                Icon(CupertinoIcons.arrow_right, size: 18, color: Colors.white,)
                              ],
                            )
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget confirmationPage() {
    return ListView(
      children: [
        isLoading? progress
        :Column(
          children: [
            Text("Send money", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text != null ? text : "100", style: TextStyle(color: Color(0xff00264E), fontSize: 60, fontWeight: FontWeight.bold)),
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
      ]
    );
  }

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

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );

  _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
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
        String resultTemp = scanData.code.toString();
        result = scanData;
        print(resultTemp);
        var parts = resultTemp.split(':');
        parts[0].trim();
        var body = parts.sublist(1).join(':').trim();
        var secondPart = body.split('?');
        secondPart[1].trim();
        barcodeResult = secondPart.sublist(0)[0].toString();
        address = barcodeResult;
        scanStarted = false;
      });
    });
  }

  void sendUSDC() {
    var amount = double.parse(text);
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
      store.state.sendUSDCToken(address,amount,  selectedWalletIndex).then((value) => {
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
            isSetAmount = false;
            scanStarted = false;
            isLoading = false;
            isSendConfirmation = false;
            address = "";
            commentValue = "";
            text = "";
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
