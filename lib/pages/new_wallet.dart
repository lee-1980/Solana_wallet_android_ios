import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:fyfypay/pages/pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';


/*
 * Getting Started Page
 */
class NewWallet extends StatefulWidget {
  NewWallet({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  NewWalletState createState() => NewWalletState(this.store);
}

class NewWalletState extends State<NewWallet> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  StateWrapper store;
  late String address;
  late String networkURL;
  QRViewController? qrController;
  Barcode? result;
  bool scanStarted = false;
  bool isLoading = false;
  bool walletCreated = false;
  String barcodeResult = "";
  TextEditingController accountNameController = new TextEditingController();
  double solBalance = 0.00;
  double usdcBalance = 0.00;
  String mnemoinicValue = "";


  NewWalletState(this.store);

  void initState() {
    super.initState();
    print(this.mnemoinicValue);
  }

  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      // appBar: AppBar(title: const Text('Import wallet')),
        backgroundColor: Colors.white,
        key: scaffoldKey,
        body: Stack(
          children: [
            isLoading? progress
            :  Padding(
                padding: EdgeInsets.only(top: config.App(context).appWidth(33)),
                child: Column(
                  children: [
                    Text("Balance", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: config.App(context).appWidth(100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            walletCreated ? solBalance.toString() : "",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 50, color: Color(0xff00264E)
                              ),
                            ),
                          ),
                          Text(' SOL')
                        ],
                      ),
                    ),
                    SizedBox(
                      width: config.App(context).appWidth(100),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            walletCreated ? usdcBalance.toString() : "",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 50, color: Color(0xff00264E)
                              ),
                            ),
                          ),
                          Text(' USDC')
                        ],
                      ),
                    ),
                    SizedBox(
                      width: config.App(context).appWidth(70),
                      child:  Text(
                        walletCreated ? mnemoinicValue : "", textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontSize: 16, color: Color(0xff00264E)
                          ),
                        ),
                      ),
                    ),

                  ],
                )
            ),
            isLoading? Container()
            :Padding(
              padding: EdgeInsets.only(top: config.App(context).appHeight(40),left: config.App(context).appWidth(15), right: config.App(context).appWidth(15)),
              child:  SizedBox(
                width: config.App(context).appWidth(70),
                child : Container(
                    width: config.App(context).appWidth(100),
                    child: ListView (
                      shrinkWrap: true,
                      children: <Widget>[
                        Column(
                          children: [
                            SizedBox(height: 40,),
                            Text("Add Account Name", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
                            SizedBox(height: 40,),
                            Form(
                              autovalidateMode: AutovalidateMode.always,
                              child:  Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: config.App(context).appWidth(80),
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1, color: Color(0xff00264E)
                                            ),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: TextFormField(
                                          controller: accountNameController,
                                          decoration: const InputDecoration(
                                            hintText: 'account name',
                                          ),
                                          onChanged: (String value) async {
                                            print(value);
                                            address = value;
                                          },
                                          // initialValue: (address != null) ? address : "",
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      Padding(
                                        padding: EdgeInsets.only(top: 20, bottom: 5),
                                        child: NetworkSelector(
                                              (String url) {
                                            print(url);
                                            networkURL = url;
                                          },
                                        ),
                                      ),

                                      SizedBox(height: 100),
                                      GestureDetector(
                                        onTap: () => {
                                          addAccount()
                                        },
                                        child:  Container(
                                            width: config.App(context).appWidth(70),
                                            height: config.App(context).appWidth(13),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                    width: 2, color: Color(0xff081B2A)
                                                )
                                            ),
                                            child:  Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children :[
                                                  Icon(Icons.add, size: 20,),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Create", style: TextStyle(color: Color(0xff081B2A), fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                ]
                                            )
                                        ),
                                      ),


                                    ],
                                  )),
                            )
                          ],
                        ),
                      ],
                    )
                )
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
                      // MaterialPageRoute(builder: (context) => PagesWidget( currentTab: 1, store: store,));
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/img/icon_arrow_backward.png'),
                  ),
                  Text("Create Wallet".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(width: 10,)
                ],
              ),
            ),
          ],
        )
    );
  }

  void addAccount() async {
    // Create the account
    if(accountNameController.text.toString().length == 0) {
      Fluttertoast.showToast(
          msg: "Input the Account Name.",
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
      store.createNewWallet(accountNameController.text.toString()).then((walletAccount) {
        accountNameController.text = "";
        Fluttertoast.showToast(
            msg: "New Wallet Created.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        setState(() {
          isLoading = false;
          walletCreated = true;
          solBalance = walletAccount.balance;
          usdcBalance = walletAccount.usdcBalance;
          mnemoinicValue = walletAccount.mnemonic;
        });
      });
    }
  }

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );

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
        scanStarted = false;
      });
    });
  }



}
