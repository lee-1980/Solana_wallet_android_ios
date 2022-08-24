import 'package:flutter/material.dart';
import 'package:solana/solana.dart'
    show
    Ed25519HDKeyPair,
    ParsedInstruction,
    ParsedMessage,
    RPCClient,
    TransactionResponse,
    Wallet;
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:solana/solana.dart';
import 'package:solana/src/rpc_client/rpc_client.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:solana/src/dto/account_data.dart';
import 'package:solana/src/dto/parsed_spl_token_account_data.dart';
import 'package:solana/src/dto/parsed_spl_token_account_data_info.dart';
import 'package:solana/src/spl_token/token_amount.dart';

import 'package:solana/src/crypto/ed25519_hd_keypair.dart';
import 'package:cryptography/cryptography.dart'
    show Ed25519, KeyPair, KeyPairType, SimpleKeyPairData, SimplePublicKey;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';

abstract class Account {
  final AccountType accountType;
  late String name;
  final String url;

  late double balance = 0;
  late double usdtBalance = 0;
  late double usdcBalance = 0;
  late String address;
  late double solValue = 0;
  late List<Transaction?> transactions = [];

  Account(this.accountType, this.name, this.url);

  Future<void> refreshBalance();
  Future<void> refreshUSDCBalance();
  Map<String, dynamic> toJson();
  Future<void> loadTransactions();
}

class Transaction {
  final String origin;
  final String destination;
  final double ammount;
  final bool receivedOrNot;

  Transaction(this.origin, this.destination, this.ammount, this.receivedOrNot);
}

class USDCTransaction {
  final String address;
  final double balance;
  final String mint;
  final String owner;

  USDCTransaction(this.address, this.balance, this.mint, this.owner);
}

class BaseAccount {
  final AccountType accountType = AccountType.Wallet;
  final String url;
  late String name;
  late String accountName;

  late RPCClient client;
  late String address;
  late String privateKey;

  late double balance = 0;
  late double usdtBalance = 0;
  late double solValue = 0;
  late double usdcBalance = 0;
  late List<Transaction?> transactions = [];
  late List<USDCTransaction?> usdcTransactions = [];

  BaseAccount(this.balance, this.name, this.url);

  /*
   * Refresh the account balance
   */
  Future<void> refreshBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;
    this.usdtBalance = this.balance * solValue;

    print({this.balance}.toString() + "sol");
    Commitment commitment = Commitment.processed;
    //main beta net

    // var usdcBla = await client.getTokenAccountsByOwner(owner: address,
    //     mint: "8HoQnePLqPj4M7PUDzfw8e3Ymdwgc7NLGnaTUapubyvu", programId: null, commitment: commitment);

    //test net
    var usdcBla = await client.getTokenAccountsByOwner(owner: address,
        mint: "CpMah17kQEL2wqyMKt3mZBdTnZbkbfx4nqmQMFDP5vwp", programId: null, commitment: commitment);

    if(usdcBla.length > 0 ) {
      List<AssociatedTokenAccount> list = usdcBla.toList();
      for(var e in list) {
        var temp = e.account.data as AccountData;
        var parsedValue = temp as SplTokenAccountData;
        var splValue  = parsedValue.parsed as ParsedSplTokenAccountData;
        var splValueInfo  = splValue.info as ParsedSplTokenAccountDataInfo;
        var tokenAmountData  = splValueInfo.tokenAmount as TokenAmount;
        usdcBalance = double.parse(tokenAmountData.uiAmountString);
        print(tokenAmountData.uiAmountString + " USDC");
      }
    }
  }

  Future<void> refreshUSDCBalance() async {
    int balance = await client.getBalance(address);
    this.balance = balance.toDouble() / 1000000000;

    Commitment commitment = Commitment.processed;
    //main beta net

    // var usdcBla = await client.getTokenAccountsByOwner(owner: address,
    //     mint: "8HoQnePLqPj4M7PUDzfw8e3Ymdwgc7NLGnaTUapubyvu", programId: null, commitment: commitment);

    //test net
    var usdcBla = await client.getTokenAccountsByOwner(owner: address,
        mint: "CpMah17kQEL2wqyMKt3mZBdTnZbkbfx4nqmQMFDP5vwp", programId: null, commitment: commitment);

    if(usdcBla.length > 0 ) {
      List<AssociatedTokenAccount> list = usdcBla.toList();
      for(var e in list) {
        var temp = e.account.data as AccountData;
        var parsedValue = temp as SplTokenAccountData;
        var splValue  = parsedValue.parsed as ParsedSplTokenAccountData;
        var splValueInfo  = splValue.info as ParsedSplTokenAccountDataInfo;
        var tokenAmountData  = splValueInfo.tokenAmount as TokenAmount;
        usdcBalance = double.parse(tokenAmountData.uiAmountString);
        print(tokenAmountData.uiAmountString + " USDC");
      }
    }
  }
  /*
   * Load the Address's transactions into the account
   */
  Future<void> loadTransactions() async {
    final response = await client.getTransactionsList(address);
    List<TransactionResponse> responseTransactions = response.toList();

    transactions = responseTransactions.map((tx) {
      ParsedMessage? message = tx.transaction.message;

      if (message != null) {
        ParsedInstruction instruction = message.instructions[0];
        dynamic res = instruction.toJson();
        if (res['program'] == 'system') {
          dynamic parsed = res['parsed'].toJson();
          switch (parsed['type']) {
            case 'transfer':
              dynamic transfer = parsed['info'].toJson();
              bool receivedOrNot = transfer['destination'] == address;
              double ammount = transfer['lamports'] / 1000000000;
              return new Transaction(transfer['source'],
                  transfer['destination'], ammount, receivedOrNot);
            default:
            // Unsupported transaction type
              return null;
          }
        } else {
          // Unsupported program
          return null;
        }
      } else {
        return null;
      }
    }).toList();
  }
}

/*
 * Types of accounts
 */
enum AccountType {
  Wallet,
  Client,
}


class WalletAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Wallet;

  late Wallet wallet;
  final String mnemonic;

  WalletAccount(double balanceValue, name, accountName, url, this.mnemonic)
      : super(balanceValue, name, url) {
    client = RPCClient(url);
    this.name = name;
    this.accountName = accountName;
  }

  /*
   * Constructor in case the address is already known
   */
  WalletAccount.with_address(
      double bal, double usdcBal, String address, name, url, this.mnemonic)
      : super(bal, name, url) {
    this.address = address;
    client = RPCClient(url);
  }

  /*
   * Create the keys pair in Isolate to prevent blocking the main thread
   */
  static Future<Ed25519HDKeyPair> createKeyPair(String mnemonic) async {
    print("dddddddddddd");
    print(mnemonic);
    final Ed25519HDKeyPair keyPair =
    await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    return keyPair;
  }

  /*
   * Load the keys pair into the WalletAccount
   */
  Future<void> importKeyPair(String mnemonic) async {
    final Ed25519HDKeyPair keyPair =
    await Executor().execute(arg1: mnemonic, fun1: createKeyPair);

    var simplePublicKey = keyPair.extract() ;
    simplePublicKey.then((value) {
      value.extractPrivateKeyBytes().then((template) => {
        print(template)
      });

    });

  }
  Future<void> loadKeyPair() async {
    final Ed25519HDKeyPair keyPair =
    await Executor().execute(arg1: this.mnemonic, fun1: createKeyPair);
    // await Executor().execute(arg1: name, fun1: createKeyPair);
    final Wallet wallet = new Wallet(signer: keyPair, rpcClient: client);
    this.wallet = wallet;
    this.address = wallet.address;
    this.privateKey = wallet.signer.address;
    RPCClient clientTemp = RPCClient(url);
    int balance = await clientTemp.getBalance(this.address);
    double solBalance = balance.toDouble() / 1000000000;
    Commitment commitment = Commitment.processed;

    //main beta net
    // var usdcBla = await client.getTokenAccountsByOwner(owner: address,
    //     mint: "8HoQnePLqPj4M7PUDzfw8e3Ymdwgc7NLGnaTUapubyvu", programId: null, commitment: commitment);

    //test net
    var usdcBla = await clientTemp.getTokenAccountsByOwner(owner: this.address,
        mint: "CpMah17kQEL2wqyMKt3mZBdTnZbkbfx4nqmQMFDP5vwp", programId: null, commitment: commitment);

    double usdcBalance = 0.0;
    if(usdcBla.length > 0 ) {
      List<AssociatedTokenAccount> list = usdcBla.toList();
      for(var e in list) {
        var temp = e.account.data as AccountData;
        var parsedValue = temp as SplTokenAccountData;
        var splValue  = parsedValue.parsed as ParsedSplTokenAccountData;
        var splValueInfo  = splValue.info as ParsedSplTokenAccountDataInfo;
        var tokenAmountData  = splValueInfo.tokenAmount as TokenAmount;
        usdcBalance = double.parse(tokenAmountData.uiAmountString);
      }
    }
    this.balance = solBalance;
    this.usdcBalance = usdcBalance;

  }

  /*
   * Create a new WalletAccount with a random mnemonic
   */
  static Future<WalletAccount> generate(String my_mnemonic, String url, name) async {
    final String randomMnemonic = bip39.generateMnemonic(strength: 256);

    WalletAccount account = new WalletAccount( 0, name, name, url, my_mnemonic);
    await account.loadKeyPair();

    // await account.refreshBalance();
    return account;
  }

  static Future<WalletAccount> generateNewWallet( String url, name, accountName) async {
    final String randomMnemonic = bip39.generateMnemonic(strength: 256);

    WalletAccount account = new WalletAccount( 0, name, accountName, url, randomMnemonic);
    await account.loadKeyPair();

    // await account.refreshBalance();
    return account;
  }


  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "url": url,
      "mnemonic": mnemonic,
      "accountType": accountType.toString()
    };
  }
}

/*
 * Simple Address Client to watch over an specific address
 */
class ClientAccount extends BaseAccount implements Account {
  final AccountType accountType = AccountType.Client;

  ClientAccount(address, double balance, name, url)
      : super(balance, name, url) {
    this.address = address;
    this.client = RPCClient(this.url);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "balance": balance,
      "usdc_balance": usdcBalance,
      "url": url,
      "accountType": accountType.toString()
    };
  }
}

class AppState {
  late Map<String, WalletAccount> accounts = Map();
  late double solValue = 0;

  AppState(this.accounts);

  static AppState? fromJson(dynamic data) {
    if (data == null) {
      return null;
    }

    try {
      Map<String, dynamic> accounts = data["accounts"];

      Map<String, WalletAccount> mappedAccounts =
      accounts.map((accountName, account) {

        // Convert enum from string to enum
        // AccountType accountType =
        // account["accountType"] == AccountType.Client.toString()
        //     ? AccountType.Client
        //     : AccountType.Wallet;
        // if (accountType == AccountType.Client) {
        //   ClientAccount clientAccount = ClientAccount(
        //     account["address"],
        //     account["balance"],
        //     accountName,
        //     account["url"],
        //   );
        //   return MapEntry(accountName, clientAccount);
        // } else {
        //   WalletAccount walletAccount = new WalletAccount.with_address(
        //     account["balance"],
        //     account["address"],
        //     accountName,
        //     account["url"],
        //     account["mnemonic"],
        //   );
        //   return MapEntry(accountName, walletAccount);
        // }
        WalletAccount walletAccount = new WalletAccount.with_address(
          account["balance"],
          account["usdcBalance"],
          account["address"],
          accountName,
          account["url"],
          account["mnemonic"],
        );
        return MapEntry(accountName, walletAccount);

      });

      return AppState(mappedAccounts);
    } catch (err) {
      /*
       * Restart the settings if there was any error
       */
      return AppState(Map());
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> savedAccounts =
    accounts.map((name, account) => MapEntry(name, account.toJson()));

    return {
      'accounts': savedAccounts,
    };
  }

  Future<void> loadSolValue() async {
    Map<String, String> headers = new Map();
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';

    Http.Response response = await Http.get(
      Uri.http(
        'api.coingecko.com',
        '/api/v3/simple/price',
        {
          'ids': 'solana',
          'vs_currencies': 'USD',
        },
      ),
      headers: headers,
    );
    print(response.body.toString());
    print("2222222222222222222222222222222");
    final body = json.decode(response.body);

    solValue = body['solana']['usd'].toDouble();

    for (final account in accounts.values) {
      account.solValue = solValue;
      await account.refreshBalance();
    }
  }

  String generateAccountName() {
    int accountN = 0;
    while (accounts.containsKey("Account $accountN")) {
      accountN++;
    }
    return "Account $accountN";
  }

  void addAccount( account) {
    account.solValue = solValue;
    accounts[account.name] = account;
  }

  Future<bool> sendUSDCToken(String address, double amount, int selectedWalletIndex) async {
    bool returnValue = false;
    WalletAccount walletAccount   ;
    walletAccount = accounts.values.elementAt(selectedWalletIndex);
    Wallet wallet = walletAccount.wallet;
    print("778888888888888888888888888");
    print(address);
    var mintValue = "CpMah17kQEL2wqyMKt3mZBdTnZbkbfx4nqmQMFDP5vwp";
    int lamports = (amount * 1000000).toInt();
    Commitment commitment = Commitment.processed;

    try {
      // this is usdc transfer
      await wallet.transferSplToken(
        mint: mintValue,
        destination: address,
        amount: lamports,
        commitment: commitment,
      );
      // this is sol transfer
      // wallet.transfer(
      //   destination: address,
      //   lamports: lamports,
      // );
      returnValue = true;
    } catch (e) {
      print(e);
      returnValue = false;
    }
    return returnValue;
  }
}

/*
 * Extends Redux's store to make simpler some interactions to the internal state
 */
class StateWrapper extends Store<AppState> {
  StateWrapper(Reducer<AppState> reducer, initialState, middleware)
      : super(reducer, initialState: initialState, middleware: middleware);

  Future<void> refreshAccounts() async {

    for (var accountEntry in state.accounts.entries.toList()) {
      WalletAccount account = accountEntry.value;
      if (account != null) {
        // Refresh the account transactions
        // await account.loadTransactions();
        // Refresh the account balance
        await account.refreshUSDCBalance();
        account.importKeyPair(account.mnemonic);
      }
    }

    // Refresh all balances value
    // await state.loadSolValue();

    // Dispatch the change
    dispatch({"type": StateActions.SolValueRefreshed});
  }


  Future<void> createWatcher(String my_mnemonic) async {
    // state.accounts.clear();
    // ClientAccount account = new ClientAccount(address, 0,
    //     state.generateAccountName(), "https://api.mainnet-beta.solana.com");
    //
    // ClientAccount account = new ClientAccount(address, 0,
    //     state.generateAccountName(), "https://api.testnet.solana.com");

    var currentAccountLength = state.accounts.length;
    var accountName = "Account " + currentAccountLength.toString();
    WalletAccount walletAccount =
    await WalletAccount.generate(my_mnemonic, "https://api.testnet.solana.com",accountName);

    // Add the account
    state.addAccount(walletAccount);
    // Load account transactions
    // await account.refreshBalance();
    // await account.loadTransactions();

    // Add the account
    // state.addAccount(account);

    // Refresh the balances
    // await state.loadSolValue();

    dispatch({"type": StateActions.SolValueRefreshed});
  }

  Future<WalletAccount> createNewWallet(String accountName) async {
    // state.accounts.clear();
    // ClientAccount account = new ClientAccount(address, 0,
    //     state.generateAccountName(), "https://api.mainnet-beta.solana.com");
    //
    // ClientAccount account = new ClientAccount(address, 0,
    //     state.generateAccountName(), "https://api.testnet.solana.com");

    var currentAccountLength = state.accounts.length;
    var nameValue = "Account " + currentAccountLength.toString();
    WalletAccount walletAccount =
    await WalletAccount.generateNewWallet( "https://api.testnet.solana.com", nameValue, accountName);

    // Add the account
    state.addAccount(walletAccount);

    dispatch({"type": StateActions.SolValueRefreshed});
    return walletAccount;
  }

  Future<void> refreshAccount(String accountName) async {
    Account? account = state.accounts[accountName];

    if (account != null) {
      await account.loadTransactions();
      await account.refreshBalance();
      dispatch({"type": StateActions.SolValueRefreshed});
    }
  }
}

class Action {
  late StateActions type;
  dynamic payload;
}

enum StateActions {
  SetBalance,
  AddAccount,
  RemoveAccount,
  SolValueRefreshed,
}

AppState stateReducer(AppState state, dynamic action) {
  final actionType = action['type'];

  switch (actionType) {
    case StateActions.SetBalance:
      final accountName = action['name'];
      final accountBalance = action['balance'];
      state.accounts
          .update(accountName, (account) => account.balance = accountBalance);
      break;

    case StateActions.AddAccount:
      Account account = action['account'];

      // Add the account to the settings
      state.addAccount(account);
      break;

    case StateActions.RemoveAccount:
    // Remove the account from the settings
      state.accounts.remove(action["name"]);

      break;

    case StateActions.SolValueRefreshed:
      break;
  }

  return state;
}

Future<StateWrapper> createStore() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  // Try to load the previous app state
  AppState? initialState = await persistor.load();

  AppState state = initialState ?? AppState(Map());

  final StateWrapper store = StateWrapper(
    stateReducer,
    state,
    [persistor.createMiddleware()],
  );

  // Fetch the current solana value
  store.refreshAccounts();
  for (Account account in state.accounts.values) {
    // Fetch every saved account's balance
    if (account.accountType == AccountType.Wallet) {
      account = account as WalletAccount;
      /*
       * Load the key's pair and the transactions list
       */
      account.loadKeyPair().then((_) {
        store.dispatch({
          "type": StateActions.AddAccount,
          "account": account,
        });
      });
      account.loadTransactions().then((_) {
        store.dispatch({
          "type": StateActions.AddAccount,
          "account": account,
        });
      });
    } else {
      /*
       * Load the transactions list
       */
      account.loadTransactions().then((_) {
        store.dispatch({
          "type": StateActions.AddAccount,
          "account": account,
        });
      });
    }
  }

  return store;
}

