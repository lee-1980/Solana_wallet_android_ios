import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fyfypay/components/home_tab_body.dart';
import '../state/store.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';
class HomeSubPage extends StatefulWidget {
  HomeSubPage({Key? key, required this.store}) : super(key: key);

  final StateWrapper store;

  @override
  HomePageState createState() => HomePageState(this.store);
}

class HomePageState extends State<HomeSubPage> {
  final StateWrapper store;

  HomePageState(this.store);

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Account>>(converter: (store) {
      Map<String, Account> accounts = store.state.accounts;
      return accounts.entries.map((entry) => entry.value).toList();
    }, builder: (context, accounts) {
      Widget page;
      //
      // switch (currentPage) {
      // // Settings sub page
      //   case 1:
      //     page = SettingsSubPage(store);
      //     break;
      //
      // // Wallet sub page
      //   default:
      //     page = AccountSubPage(store, accounts);
      // }
      page = AccountSubPage(store, accounts);
      return Scaffold(
        body: page,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int page) {
            setState(() {
              currentPage = page;
            });
          },
          elevation: 0,
          currentIndex: currentPage,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.account_balance_wallet),
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Accounts',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      );
    });
  }
}
