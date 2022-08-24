import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyfypay/components/network_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import '../state/store.dart';
import '../utiles/app_config.dart' as config;
import 'package:qr_code_scanner/qr_code_scanner.dart';


/*
 * Getting Started Page
 */
class WatchAddress extends StatefulWidget {
  WatchAddress({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  WatchAddressState createState() => WatchAddressState(this.store);
}

class WatchAddressState extends State<WatchAddress> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  StateWrapper store;
  late String address;
  late String networkURL;
  QRViewController? qrController;
  Barcode? result;
  bool scanStarted = false;
  bool isLoading = false;
  String barcodeResult = "";
  TextEditingController mnemonicController = new TextEditingController();
  double solBalance = 0.00;
  double usdcBalance = 0.00;


  WatchAddressState(this.store);

  void initState() {
    super.initState();
    initWallets();

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
                            solBalance.toString(),
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
                            usdcBalance.toString(),
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

                    // StoreConnector<AppState, List<WalletAccount>>(converter: (store) {
                    //   Map<String, WalletAccount> accounts = store.state.accounts;
                    //   return accounts.entries.map((entry) => entry.value).toList();
                    // }, builder: (context, accounts) {
                    //   return SingleChildScrollView(
                    //     child: Row(
                    //       children:  accounts.map((account) {
                    //         return RefreshIndicator(
                    //           onRefresh: () async {
                    //             // Refresh all account's balances when pulling
                    //             await store.refreshAccounts();
                    //           },
                    //           child: NotificationListener<OverscrollIndicatorNotification>(
                    //               onNotification: (OverscrollIndicatorNotification overscroll) {
                    //                 // This disables the Material scroll effect when overscrolling
                    //                 overscroll.disallowGlow();
                    //                 return true;
                    //               },
                    //               child: Padding(
                    //                 padding: EdgeInsets.only(top: 10.0),
                    //                 child: Column(
                    //                   mainAxisAlignment: MainAxisAlignment.start,
                    //                   crossAxisAlignment: CrossAxisAlignment.center,
                    //                   children: <Widget>[
                    //                     Column(
                    //                       children: [
                    //                         Padding(
                    //                           padding: EdgeInsets.all(10),
                    //                           child: Row(
                    //                             mainAxisAlignment: MainAxisAlignment.center,
                    //                             children: [
                    //                               // Display the account's SOL ammount
                    //                               StoreConnector<AppState, String>(converter: ((store) {
                    //                                 print(account.mnemonic);
                    //                                 WalletAccount? account1 = store.state.accounts[account.name];
                    //                                 if (account1 != null) {
                    //                                   String solBalance = account1.balance.toString();
                    //                                   return solBalance;
                    //                                 } else {
                    //                                   return "0";
                    //                                 }
                    //                               }), builder: (context, solBalance) {
                    //                                 return Text(
                    //                                   solBalance,
                    //                                   style: GoogleFonts.poppins(
                    //                                     textStyle: TextStyle(
                    //                                         fontSize: 50, color: Color(0xff00264E)
                    //                                     ),
                    //                                   ),
                    //                                 );
                    //                               }),
                    //                               const Text(' SOL'),
                    //                             ],
                    //                           ),
                    //                         ),
                    //                         StoreConnector<AppState, Tuple2<bool, String>>(converter: ((store) {
                    //                           Account? account2 = store.state.accounts[account.name];
                    //                           if (account2 != null) {
                    //                             // String usdBalance = account2.usdtBalance.toString();
                    //                             String usdBalance = account2.usdcBalance.toString();
                    //                             // Cut some numbers to make it easier to read
                    //                             if (usdBalance.length >= 6) {
                    //                               usdBalance = usdBalance.substring(0, 6);
                    //                             }
                    //                             bool shouldRenderSpinner =
                    //                                 account2.balance > 0.0 && account2.usdcBalance == 0.0;
                    //                             return Tuple2(shouldRenderSpinner, usdBalance);
                    //                           } else {
                    //                             return Tuple2(false, "");
                    //                           }
                    //                         }), builder: (context, value) {
                    //                           bool shouldRenderSpinner = value.item1;
                    //                           String usdBalance = value.item2;
                    //
                    //                           if (shouldRenderSpinner) {
                    //                             return Container(
                    //                               width: 35,
                    //                               height: 35,
                    //                               child: CircularProgressIndicator(
                    //                                 strokeWidth: 3.0,
                    //                                 semanticsLabel: 'Loading SOL USD equivalent value',
                    //                               ),
                    //                             );
                    //                           } else {
                    //                             return Row(
                    //                               mainAxisAlignment: MainAxisAlignment.center,
                    //                               children: [
                    //                                 Text(
                    //                                   '$usdBalance',
                    //                                   style: GoogleFonts.lato(
                    //                                     textStyle: TextStyle(
                    //                                       fontSize: 25, color: Color(0xff00264E),
                    //                                       fontWeight: FontWeight.w900,
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                                 const Text(' USDC'),
                    //                               ],
                    //                             );
                    //                           }
                    //                         }),
                    //                       ],
                    //                     )
                    //                   ],
                    //                 ),
                    //               )
                    //           ),
                    //         );
                    //       }).toList(),
                    //     ),
                    //   );
                    // }),
                    Container(
                        width: config.App(context).appWidth(100),
                        child: ListView (
                          shrinkWrap: true,
                          children: <Widget>[
                            Column(
                              children: [
                                SizedBox(height: 40,),
                                Text("My Wallet Address", style: TextStyle(color: Color(0xff00264E), fontSize: 24, fontWeight: FontWeight.w600)),
                                SizedBox(height: 40,),
                                Form(
                                  autovalidateMode: AutovalidateMode.always,
                                  child:  Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        children: [
                                          Container(
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
                                                GestureDetector(
                                                  onTap: () {
                                                    // setState(() {
                                                    //   scanStarted = true;
                                                    // });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: Color(0xff00264E)
                                                    ),
                                                    child: Image.asset('assets/img/icon_qr_code.png'),
                                                  ),
                                                ),
                                                SizedBox(width: 20,),

                                                SizedBox(
                                                  width: config.App(context).appWidth(50),
                                                  child:  TextFormField(
                                                    controller: mnemonicController,
                                                    decoration: const InputDecoration(
                                                      hintText: 'Mnemonic',
                                                    ),
                                                    onChanged: (String value) async {
                                                      print(value);
                                                      address = value;
                                                    },
                                                    // initialValue: (address != null) ? address : "",
                                                  ),
                                                  // child: Text("28v5kipdi...sdewDoS43", style: TextStyle(color: Color(0xff00264E), fontSize: 18, fontWeight: FontWeight.w400)),
                                                ),

                                              ],
                                            ),
                                          ),
                                          // SizedBox(height: 20,),
                                          // Padding(
                                          //   padding: EdgeInsets.only(top: 20, bottom: 5),
                                          //   child: NetworkSelector(
                                          //         (String url) {
                                          //           print(url);
                                          //       networkURL = url;
                                          //     },
                                          //   ),
                                          // ),

                                          SizedBox(height: 50),
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
                                                        "add wallet", style: TextStyle(color: Color(0xff081B2A), fontSize: 18, fontWeight: FontWeight.w600),
                                                      ),
                                                    ]
                                                )
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () => {
                                              Navigator.of(context).pushNamed('/new_wallet')
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
                                                        "create new wallet", style: TextStyle(color: Color(0xff081B2A), fontSize: 18, fontWeight: FontWeight.w600),
                                                      ),
                                                    ]
                                                )
                                            ),
                                          ),

                                        ],
                                      )),
                                ),
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
                                      return GestureDetector(
                                        onTap: () {
                                          setState((){
                                            solBalance = store.state.accounts["Account " + index.toString()]!.balance;
                                            usdcBalance = store.state.accounts["Account " + index.toString()]!.usdcBalance;
                                          });
                                        },
                                        child: Container(
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
                                                store.state.accounts["Account "+ index.toString()]!.accountName, style: TextStyle(color: Color(0xff081B2A), fontSize: 14, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),



                          ],
                        )
                    )
                  ],
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
                  Image.asset('assets/img/icon_arrow_backward.png'),
                  Text("My Wallet".toUpperCase()  , style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(width: 10,)
                ],
              ),
            ),
          ],
        )
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

  void initWallets() {
    if(store.state.accounts.length > 0) {
      setState(() {
        isLoading = true;
      });
      store.refreshAccounts().then((_) {
        setState(() {
          isLoading = false;
          solBalance = store.state.accounts["Account 0"]!.balance;
          usdcBalance = store.state.accounts["Account 0"]!.usdcBalance;
          print(store.state.accounts["Account 0"]!.address);
          print(store.state.accounts["Account 0"]!.accountName);
          print(store.state.accounts["Account 0"]!.mnemonic);
        });
      });
    }
  }

  void addAccount() async {
    // Create the account
    if(mnemonicController.text.toString().length == 0) {
      Fluttertoast.showToast(
          msg: "Input the Mnemonic.",
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
      store.createWatcher(mnemonicController.text.toString()).then((_) {
        mnemonicController.text = "";
        Fluttertoast.showToast(
            msg: "New Wallet Added.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        setState(() {
          isLoading = false;
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
