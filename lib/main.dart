import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'UI/config.dart';
import 'app.dart';
import 'dart:io';
import 'dart:convert';

import 'bloc/app_bloc.dart';
import 'dart:async';

import 'bloc/user_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,//縦固定
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom
  ]);
  await Firebase.initializeApp();

  runApp(MainScreen());
}
class MainScreen extends StatefulWidget {
  final String? currentUserId;

  MainScreen({Key? key, this.currentUserId}) : super(key: key);

  @override
  State createState() => MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {
  MainScreenState({Key? key, this.currentUserId});

  String? currentUserId;
  int? initScreen = 0 ;
  bool newNotificationChat = false;
  String? token;
  FirebaseMessaging? firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationDetails? platformChannelSpecifics;
  String? groupId;

  final GlobalKey<NavigatorState>? _navigator = GlobalKey<NavigatorState>();

  bool isLoading = false;
  var prefs;

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    '魔法の質問', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  getPrefs() async{
    print("Called getCurrentUserId");
    prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString(Config.prefsId) ?? '';
//    groupId = prefs.getString(Config.prefsGroupId) ?? null;
    print("MainScreenState - getPrefs - currentUserId: $currentUserId");
//    print("MainScreenState - getPrefs - groupId: $groupId");
  }

  @override
  void initState(){
    super.initState();
    getPrefs();
    setForegroundNotification();
//    configLocalNotification();

    firebaseMessaging!.getToken().then((pushToken) async{
      print('MainScreenState　-　initState - pushToken: $pushToken');
      print('MainScreenState　-　initState - currentUserId1: $currentUserId');

      await prefs.setString(Config.prefsPushToken, pushToken);
      currentUserId = prefs.getString(Config.prefsId) ?? '';

      if(currentUserId != null && currentUserId!.length >0 ) {
        await UsersBloc.getInstance()!.updatePushToken(currentUserId, pushToken);
      }

    }).catchError((err) {
      print('MainScreenState　-　initState - err: $err');
      AppBloc.getInstance()!.showError(err);
//      Fluttertoast.showToast(msg: err.message.toString());
    });

    firebaseMessaging!.requestPermission(
        sound: true, badge: true, alert: true, provisional: true, announcement: false);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('fMainScreenState　-　irebaseMessaging - onMessage: $message');
        print('MainScreenState　-　firebaseMessaging - onMessage: ${getScreen(message)}');

        setState(() {
          groupId = getGroupId(message);
          if(getScreen(message) == '/home' && groupId != null && groupId!.length > 0){
            newNotificationChat = true;
          }
          else{
            newNotificationChat = false;
          }
        });
        print('MainScreenState　-　firebaseMessaging - onMessage: $newNotificationChat ');
        _showItemDialog(message);
        return;
    });


    // FirebaseMessaging.onBackgroundMessage((message) {
    //   print('MainScreenState　-　firebaseMessaging - onResume: $message');
    //   print('MainScreenState　-　firebaseMessaging - onResume: ${getScreen(message)}');
    //   setState(() {
    //     groupId = getGroupId(message);
    //
    //     if(getScreen(message) == '/home' && groupId != null && groupId.length > 0){
    //       newNotificationChat = true;
    //     }
    //     else{
    //       newNotificationChat = false;
    //     }
    //   });
    //   print('MainScreenState　-　firebaseMessaging - onResume: $newNotificationChat');
    //   _navigateToItemDetail(message.data);
    //   return;
    // });

    // firebaseMessaging.configure(
    //     onMessage: (Map<String, dynamic> message) {
    //       print('fMainScreenState　-　irebaseMessaging - onMessage: $message');
    //       print('MainScreenState　-　firebaseMessaging - onMessage: ${getScreen(message)}');
    //
    //       setState(() {
    //         groupId = getGroupId(message);
    //         if(getScreen(message) == '/home' && groupId != null && groupId.length > 0){
    //           newNotificationChat = true;
    //         }
    //         else{
    //           newNotificationChat = false;
    //         }
    //       });
    //       print('MainScreenState　-　firebaseMessaging - onMessage: $newNotificationChat ');
    //       _showItemDialog(message);
    //       return;
    //     },
    //     onResume: (Map<String, dynamic> message){
    //
    //       return;
    //     },
    //     onLaunch: (Map<String, dynamic> message) {
    //       print('MainScreenState　-　firebaseMessaging - onLaunch: $message');
    //       print('MainScreenState　-　firebaseMessaging - onLaunch: ${getScreen(message)}');
    //       setState(() {
    //         groupId = getGroupId(message);
    //         if(getScreen(message) == '/home' && groupId != null && groupId.length > 0){
    //           newNotificationChat = true;
    //         }
    //         else{
    //           newNotificationChat = false;
    //         }
    //       });
    //       print('MainScreenState　-　firebaseMessaging - onLaunch: $newNotificationChat');
    //       _navigateToItemDetail(message);
    //       return;
    //     }
    // );

//    registerNotification();
  }

  void setForegroundNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<dynamic> setScreenPrefs() async{
    prefs = prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(Config.prefsInit, true);
    print("MainScreenState　-　setPrefs - prefsInit         : ${prefs.getBool(Config.prefsInit)}");
  }

  //has to confirm *****
  String getScreen(message){
    return Platform.isAndroid ? message.data['screen']: message['screen'];
  }

  String getGroupId(message){
    return Platform.isAndroid ? message.data['groupId']: message['groupId'];
  }

  Future<dynamic> setPrefs() async{
    prefs = prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(Config.prefsNewNotificationChat, newNotificationChat ?? false);
//    await prefs.setBool(Config.groupId, groupId ?? null);

    print("MainScreenState　-　setPrefs - newNotificationChat: ${prefs.getBool(Config.prefsNewNotificationChat)}");
//    print("MainScreenState　-　setPrefs - groupId: ${prefs.getBool(Config.groupId)}");
  }

  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      content: Text(""),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        ElevatedButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(RemoteMessage message) {
    print("MainScreenState　-　_showItemDialog");

    Fluttertoast.showToast(msg: message.notification!.title.toString() + ": "
    + message.notification!.body.toString());

  }
  //PRIVATE METHOD TO HANDLE NAVIGATION TO SPECIFIC PAGE
  void _navigateToItemDetail(Map<String, dynamic> message) async{
    print("MainScreenState　-　_navigateToItemDetail - route               : " + getScreen(message)??"/home");
//    print("MainScreenState　-　_navigateToItemDetail - url                 : " + getScreen(message) == "/latest" ?  Platform.isAndroid ? message['data']['url']: message['url'] : "blank");
    print("MainScreenState　-　_navigateToItemDetail - currentUserId       : " + currentUserId!??"");
    print("MainScreenState　-　_navigateToItemDetail - newNotificationChat : " + newNotificationChat.toString());

    await setPrefs(); //update

    if(_navigator != null && _navigator!.currentContext != null){
      _navigator!.currentState?.pushNamed(getScreen(message)?? "/home");
    }

  }


  void configLocalNotification() async{
    await setScreenPrefs();
    print("MainScreenState　-　Called configLocalNotification");
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new DarwinInitializationSettings();
    var initializationSettings = new InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS
    );
    flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await onSelectNotification(response.payload);
      }
    );

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
      icon: 'app_icon'
    );
    var iOSPlatformChannelSpecifics = new DarwinNotificationDetails();
    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  }


  Future onSelectNotification(message) async{
    print("MainScreenState　-　onSelectNotification: $message");
    showDialog(context: context,
      builder: (_) => new AlertDialog(
        title: new Text(message.notification.title.toString()),
        content: new Text(message.notification.body.toString()),
      ),
    );
  }

  // void showNotification(message) async {
  //   print("Called showNotification");
  //   print("json.encode(message): ${json.encode(message)}");
  //   await flutterLocalNotificationsPlugin.show(
  //       0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
  //       payload: json.encode(message));
  // }

  @override
  Widget build(BuildContext context) {
//    groupId = "0TbNumLeDage4RsA0jpm";
    print("MainScreenState　-　MainScreen - build");
    print("MainScreenState　-　MainScreen - build - currentUserId: $currentUserId");
    print("MainScreenState　-　MainScreen - build - initScreen: $initScreen");
    print("MainScreenState　-　MainScreen - build - newNotificationChat: $newNotificationChat");
    print("MainScreenState　-　MainScreen - build - groupId: $groupId");

    // TODO: implement build
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        navigatorKey: _navigator,
        routes: <String, WidgetBuilder>{

          '/home': (context) => MyAppMain(currentUserId: currentUserId
              , initScreen: initScreen ?? 0, newNotificationChat: newNotificationChat??false, groupId: groupId),
//          '/chat1v1': (context) =>   MyAppMain(
//              currentUserId: currentUserId
//              , initScreen: initScreen ?? 2, newNotificationChat: newNotificationChat),
        },
        theme: ThemeData(
              primarySwatch: Colors.amber,
              primaryColor: Colors.amber[800],
              primaryColorDark: Colors.amber.shade400,
//            accentColor: Colors.white
        ),
        home: new MyAppMain(currentUserId: currentUserId, initScreen: 0, newNotificationChat: newNotificationChat, groupId: groupId),

    );
  }

}