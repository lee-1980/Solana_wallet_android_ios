import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class App {
//   BuildContext context;
//   double height;
//   double width;
//   double heightPadding;
//   double widthPadding;
//
//   // App(context) {
//   //   this._context = _context;
//     MediaQueryData _queryData = MediaQuery.of(this._context);
//     height = _queryData.size.height / 100.0;
//     width = _queryData.size.width / 100.0;
//     heightPadding = height - ((_queryData.padding.top + _queryData.padding.bottom) / 100.0);
//     widthPadding = width - (_queryData.padding.left + _queryData.padding.right) / 100.0;
//   // }
//   App({
//     required this.context,
//     required this.height,
//     required this.width,
//     required this.heightPadding,
//     required this.widthPadding,
//   })
//
//   double appHeight(double v) {
//     return height * v;
//   }
//
//   double appWidth(double v) {
//     return width * v;
//   }
//
//   double appVerticalPadding(double v) {
//     return heightPadding * v;
//   }
//
//   double appHorizontalPadding(double v) {
// //    int.parse(settingRepo.setting.mainColor.replaceAll("#", "0xFF"));
//     return widthPadding * v;
//   }
// }
class App {
  BuildContext context;


  App(this.context);

  double appHeight(double v) {
    MediaQueryData _queryData = MediaQuery.of(this.context);
    final height = _queryData.size.height / 100.0;
    return height * v;
  }

  double appWidth(double v) {
    MediaQueryData _queryData = MediaQuery.of(this.context);
    final width = _queryData.size.width / 100.0;
    return width * v;
  }

  double appVerticalPadding(double v) {
    MediaQueryData _queryData = MediaQuery.of(this.context);
    final height = _queryData.size.height / 100.0;
    final heightPadding = height - ((_queryData.padding.top + _queryData.padding.bottom) / 100.0);
    return heightPadding * v;
  }

  double appHorizontalPadding(double v) {
    MediaQueryData _queryData = MediaQuery.of(this.context);
    final width = _queryData.size.width / 100.0;
    final widthPadding = width -
        (_queryData.padding.left + _queryData.padding.right) / 100.0;
    return widthPadding * v;
  }

  Future<bool> onWillPop() {
    DateTime currentBackPressTime = DateTime.now();
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      // Fluttertoast.showToast(msg: S.of(context).tapAgainToLeave);
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }


}
