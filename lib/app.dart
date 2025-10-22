import 'dart:async';

//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_crashlytics/flutter_crashlytics.dart';
//import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shitsumon/UI/labels.dart';
import 'package:shitsumon/bloc/app_bloc.dart';
import 'package:shitsumon/chat/chat_list.dart';
import 'package:shitsumon/providers/google_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart';

import 'UI/config.dart';
import 'UI/size_config.dart';
import 'event/event.dart';
import 'officialhp/officialhp.dart';
import 'qa/qa.dart';
import 'shop/shop.dart';

// import 'networking_page_header.dart';

class MyAppMain extends StatefulWidget {
  String? currentUserId;
  int? initScreen = 0;
  bool? newNotificationChat = false;
  String? groupId;
  MyAppMain({Key? key, this.currentUserId, this.initScreen, this.newNotificationChat, this.groupId}) : super(key: key);

  @override
  _MyAppMainState createState() => _MyAppMainState(
      currentUserId: currentUserId
      , initScreen: initScreen
      , newNotificationChat: newNotificationChat
      , groupId: groupId);
}

class _MyAppMainState extends State<MyAppMain> {
  int _currentIndex = 0;
  List<Widget> menu = [];
  // String calendarName = "primary";
  GoogleProvider _googleClient = new GoogleProvider();
  bool isLoading = false;
  bool signIn = false;
  // String adminCalendar;
  String? currentUserId;
  bool? newNotificationChat = false;
  int? initScreen = 0;
  String? groupId;

  var prefs;

  _MyAppMainState({this.currentUserId, this.initScreen, this.newNotificationChat, this.groupId}) {
    print('_MyAppMainState1 - currentUserId      : $currentUserId');
    print('_MyAppMainState1 - initScreen         : $initScreen');
    print('_MyAppMainState1 - newNotificationChat: $newNotificationChat');
    print('_MyAppMainState1 - groupId: $groupId');

    AppBloc.getInstance()!.user.listen((status) async {
      prefs = await SharedPreferences.getInstance();
      getPrefs();
      print("_MyAppMainState 2 - currentUserId: $currentUserId");
      print("_MyAppMainState 2 - groupId: $groupId");

      setState(() {
        this.signIn = status;
      });
//      getMenu(status);
    });
    AppBloc.getInstance()!.onError.listen((error) async {
//      await FlutterCrashlytics().reportCrash(error, , forceCrash: false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("エラー"),
            content: new Text(error),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new ElevatedButton(
                child: new Text("閉じる"),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isLoading) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    });
    AppBloc.getInstance()!.isLoading.listen((status) {
      if (status && !isLoading) {
        setState(() {
          isLoading = status;
        });
        _onLoading();
      } else if (!status && isLoading) {
        Navigator.pop(context);
      }
    });
  }

  void getPrefs() async{
    prefs = prefs ?? await SharedPreferences.getInstance();
    currentUserId = await prefs.getString(Config.prefsId) ?? '';
    print("_MyAppMainState 2 - currentUserId: $currentUserId");
    newNotificationChat = await prefs.getBool(Config.prefsNewNotificationChat) ?? false;
//    groupId = await prefs.getString(Config.prefsGroupId) ?? null;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
//      getMenu(this.signIn);
    });
  }

  Widget getTab(int index) {
    if (index == 0){
      print('_MyAppMainState 1 - groupId: $groupId');
//      print('_MyAppMainState 1 - prefsGroupId: ${prefs!=null?prefs.getString(Config.prefsGroupId):""}');

      updatePrefs(Config.prefsNewNotificationChat, false);
      // if(groupId == null) {

        print('_MyAppMainState 2 - groupId: $groupId');
        return ChatList(currentUserId: currentUserId);
//       }else{
//         getPrefs();
//         print('_MyAppMainState 3 - groupId: $groupId');
//         var paramGroupId = groupId;
//         groupId = null;
//         return Chat(
//           chatRoomId: paramGroupId,
//           currentUserId: currentUserId,
//           chatRoomName:  Config.getChatRoomeName(paramGroupId),
//           groupId: paramGroupId,
//         );
// //        print('_MyAppMainState 2 - prefsGroupId: ${prefs!=null?prefs.getString(Config.prefsGroupId):""}');
//       }

    }else if (index == 1) {
      return EventScreen();
    } else if (index == 2){
      return ShopScreen();
    }else if (index == 3){
      return OfficialHpScreen();
//      return WebViewScreen(url: Strings.shop_url);
//      return ShopScreen();
    }else if(index == 4){
      return QAScreen();
//      return WebViewScreen(url: Strings.lounge_url);
    }else{
      return ChatList(currentUserId: currentUserId);
    }
  }

  void updatePrefs(category, value) async{
    prefs = prefs ?? await SharedPreferences.getInstance();
    if(category == Config.prefsNewNotificationChat) await prefs.setBool(Config.prefsNewNotificationChat, value);
//    if(category == Config.prefsGroupId){
//      await prefs.setString(Config.prefsGroupId, value);
//      print('_MyAppMainState - updatePrefs - prefsGroupId: $value');
//    }
  }

  void _onLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return new Dialog(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                Padding(
                    padding: EdgeInsets.only(left: 10), child: Text("Loading")),
              ]),
            ),
          );
        }).then((res) => setState(() {
      print(res);
      isLoading = false;
    }));
  }


  contact() async {
    if (await canLaunch(Strings.contact_url)) {
      await launch(Strings.contact_url);
    }
  }

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    getPrefs();
    // if(initScreen != 0 &&(newNotificationChat)){
    //   _currentIndex = initScreen;
    // }
    print("app - build - newNotificationChat: $newNotificationChat");
    print("app - build - groupId: $groupId");

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
//      appBar: GradientAppBar(
//        title: //Image.asset('images/appbarimage.jpg', fit: BoxFit.cover),
//
////        Row(
////          mainAxisAlignment: MainAxisAlignment.center,
////          children: [
////          Image.asset(
////            'images/appbarimage.jpg',
////            fit: BoxFit.contain,
////            height: 32,
////          ),
//////            IconButton(
//////              icon: CircleAvatar(
//////                backgroundImage: AssetImage('images/appbarimage.jpg'),
//////                backgroundColor: Colors.transparent, // 背景色
////////                radius: 13, // 表示したいサイズの半径を指定
//////              ),
////////          onPressed: /* タップした時の処理 */,
//////            ),
////            Container(
////                padding: const EdgeInsets.all(8.0), child: Text('App Name')
////            )
////          ],
////        ),
//          Container(
//            width: MediaQuery.of(context).size.width,
//            height: 100,
//            decoration: BoxDecoration(
//              image: DecorationImage(
//                fit: BoxFit.fill,
//                image: AssetImage("images/appbarimage.jpg"),
//              ),
//            ),
//          ),
//    backgroundColorStart: Theme.of(context).primaryColor,
//        backgroundColorEnd: Colors.blue,
//        actions: menu,
//        leading: Container(
//          width: MediaQuery.of(context).size.width,
//          height: 100,
//          decoration: BoxDecoration(
//            image: DecorationImage(
//              fit: BoxFit.fill,
//              image: AssetImage("images/appbarimage.jpg"),
//            ),
//          ),
//        ),
//      ),
//      body:
//      CustomScrollView(
//        slivers: <Widget>[
//          SliverPersistentHeader(
//  //              title: Text("hello"),
//  //            maxExtent: 60,
//            floating: true,
//            pinned: true,
//    //            snap: true,
//            delegate: NetworkingPageHeader(
//              minExtent: 60.0,
//              maxExtent: 60.0,
//            ),
//          ),
//          SliverList(
//            delegate: SliverChildBuilderDelegate(
//              (BuildContext context, int index) {
//                return getTab(_currentIndex);
//              },
//                childCount: 2,
//                semanticIndexOffset: 2,
//              ),
//
//            ),
//            SliverList(
//            delegate: SliverChildListDelegate([
//              SizedBox(
//                height: MediaQuery.of(context).size.height, // or something simular :)
//                  child:
//                  new Column(
//                    mainAxisSize: MainAxisSize.max,
//                    children: <Widget>[
//                      new Expanded(
//                        child: getTab(_currentIndex),
//                      ),
//                    ],
//                   ),
//              ),
//            ]),
//          )
//        ],
//      ),

      appBar: AppBar(
          title: new Text(groupId == null || groupId!.isEmpty ?
            Strings.title : Config.getChatRoomeName(groupId), style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
//          backgroundColorStart: Theme.of(context).primaryColor,
//          backgroundColorEnd: Theme.of(context).primaryColorDark,
          leading: _currentIndex == 0 ? new Container() : NavigationBackControls(_controller.future),
          actions: _currentIndex == 0 ? [] : <Widget>[
          NavigationControls(_controller.future)]
      ),
      body: SafeArea(child: getTab(_currentIndex)),
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.black54,
          currentIndex: _currentIndex,
          selectedLabelStyle: textTheme.bodySmall,
          unselectedLabelStyle: textTheme.bodySmall,
//          selectedFontSize: 8,
//          unselectedFontSize: 8,
          items: [
            BottomNavigationBarItem(
                icon: newNotificationChat!
                    ? Stack(
                  children: <Widget>[
                    Icon(Icons.chat),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                        child: Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                )
                    : Icon(Icons.chat),
                label: "お知らせ"),
            BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: "イベント"),

            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "SHOP"),
            BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on),
                label: "TOIN"),
            BottomNavigationBarItem(
                icon: Icon(Icons.mail),
                label: "お問い合わせ"),

          ]),

    );
  }

}

WebViewController? controllerGlobal;

class NavigationBackControls extends StatelessWidget {
  const NavigationBackControls(this._webViewControllerFuture);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
              onPressed: () async {
                if (await controllerGlobal!.canGoBack()) {
                  controllerGlobal!.goBack();
                } else {
                  // Scaffold.of(context).showSnackBar(
                  //   const SnackBar(content: Text("No back history item")),
                  // );
                  return;
                }
              },
            ),
          ],
        );
      },
    );
  }
}
class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onPressed: () async {
                if (await controllerGlobal!.canGoForward()) {
                  controllerGlobal!.goForward();
                } else {
                  // Scaffold.of(context).showSnackBar(
                  //   const SnackBar(
                  //       content: Text("No forward history item")),
                  // );
                  return;
                }
              },
            ),
          ],
        );
      },
    );
  }
}