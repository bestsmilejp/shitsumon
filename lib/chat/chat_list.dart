import 'dart:async';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shitsumon/UI/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shitsumon/UI/labels.dart';
import 'package:shitsumon/bloc/app_bloc.dart';
import 'package:shitsumon/bloc/chat_bloc.dart';
import 'package:shitsumon/chat/chat.dart';
import 'package:shitsumon/models/ChatRoom.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class ChatList extends StatelessWidget {
final String? chatRoomId;
final String? currentUserId;
final String? chatRoomName;

ChatList({Key? key,
this.chatRoomId,
required this.currentUserId,
this.chatRoomName})
    : super(key: key);

@override
Widget build(BuildContext context) {
  print("Chat build 1 - this.chatRoomId: ${this.chatRoomId}");
  print("Chat build 1 - this.currentUserId: ${this.currentUserId}");
  print("Chat build 1 - this.chatRoomName: ${this.chatRoomName}");

  return
    new Scaffold(
//      appBar: AppBar(
//          title: Text(Strings.title, style: TextStyle(color: Colors.white)),
////          gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark]),
//          iconTheme: IconThemeData(color: Colors.white),
//          leading: new Container(),
//          centerTitle: true,
//      ),
      body: ChatListScreen(
        chatRoomId: chatRoomId,
        currentUserId: currentUserId,
        chatRoomName: chatRoomName,
      ),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  final String? currentUserId;
  final String? chatRoomId;
  final String? chatRoomName;

  ChatListScreen(
      {Key? key,
        required this.currentUserId,
        this.chatRoomId,
        this.chatRoomName
      })
      : super(key: key);

  @override
  State createState() => ChatListScreenState(currentUserId: currentUserId);
}

class ChatListScreenState extends State<ChatListScreen> {
  List<StreamSubscription> subs = [];

  String? name;

  ChatListScreenState({Key? key, required this.currentUserId});

  var chatRooms = <ChatRoom>[];
  String? currentUserId;

  bool isLoading = false;

  @override
  dispose() {
    subs.forEach((s) => s.cancel());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(currentUserId == null || currentUserId?.length == 0){
      AppBloc.getInstance()!.login();
    }
    this.subs.add(AppBloc.getInstance()!.user.listen((status) async {
      if (status) {
        var prefs = await SharedPreferences.getInstance();
        setState(() {
          currentUserId = prefs.getString(Config.prefsId) ?? '';
//          groupId = prefs.getString(Config.prefsGroupId) ?? '';
//          print('ChatListScreenState - initState 2 - groupId: $groupId');

          print("ChatListScreenState - initState 2 - initState - currentUserId: $currentUserId");
        });

        ChatBloc.getInstance()!
            .getChatRooms(widget.chatRoomId??"");
      } else {
        setState(() {
          chatRooms = [];
          currentUserId = null;
        });
      }
    }));

    this.subs.add(ChatBloc
        .getInstance()!
        .chatRooms
        .listen((chatRooms) async {
      setState(() {
        this.chatRooms = chatRooms;
      });
    }));

  }

//  String getTrimmedMessage(String message) {
//    if (message != null) {
//      return message.length > 15 ? message.substring(0, 15) : message;
//    }
//    return 'No Messages';
//  }


  Widget buildItem(BuildContext context, ChatRoom document) {
//    print('latestMsgTimestamp');
//    print(document.latestMsgTimestamp);
//    print(document.latestMsgTimestamp!=null);
    print("ChatListScreenState buildItem 1 - document.name: ${document.name}");

    return Container(
      child: Card(
        color: Theme.of(context).secondaryHeaderColor,
        margin: EdgeInsets.only(top: 5),
        elevation: 0,
        child: InkWell(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                if (document.name != null) {
                  print("ChatListScreenState buildItem 2 - ");
                  return Chat(
                    chatRoomId: document.id??"",
                    currentUserId: currentUserId??"",
                    chatRoomName: document.name??"",
                  );
                } else {
                  return ChatListScreen(
                    currentUserId: currentUserId,
                    chatRoomId: document.id,
                    chatRoomName: document.name,
                  );
                }
              })).then((a) => ChatBloc.getInstance()!
                  .getChatRooms(widget.chatRoomId)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 25, 10, 25),
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${document.name}',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    document.latestMsgTimestamp != null && int.tryParse(document.latestMsgTimestamp??"0") != null?
                    Container(
                      child: Text(
                        document.latestMsgTimestamp != null && int.tryParse(document.latestMsgTimestamp??"0") != null
                            ? '${DateFormat('yyyy/MM/dd hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(document.latestMsgTimestamp??"0")!))}'
                            : "",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: '${document.latestMsgTimestamp}' != null
                                ? 12
                                : 0),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ):
                    Container(
                      child: Text("", style: TextStyle(fontSize: 0),
                    ),)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

//  ChatRoom getChatInfoByChatRoomId(){
//    chatRooms.forEach((element) {
//      if(this.groupId == element.id){
//        return element;
//      }
//    });
//  }

  Widget buildScreen(BuildContext context) {

    return Stack(
      children: <Widget>[
        // List
        Container(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chatRooms.length,
              padding: EdgeInsets.only(top: 5),
              itemBuilder: (context, index) =>
                  buildItem(context, chatRooms[index]),
            ))
            ,
        // Loading
        Positioned(
          child: isLoading
              ? Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)),
            ),
            color: Colors.white.withOpacity(0.8),
          )
              : Container(),
        )
      ],
    );
  }

//  getPrefs() async {
//    if(prefs == null) prefs = await SharedPreferences.getInstance();
//    currentUserId = prefs.getString(Config.prefsId) ?? '';
//    groupId = prefs.getString(Config.groupId) ?? '';

//    print("ChatListScreenState build 1 - prefs.groupId: ${prefs.getString(Config.groupId)}");

//  }

//  void updatePrefs(category, flag) async{
//    prefs = prefs ?? await SharedPreferences.getInstance();
//    if(category == Config.groupId) await prefs.setString(Config.groupId, flag);
//  }


  Future<bool> onBackPress() {
    // Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chatRoomId == null)
      return WillPopScope(
        onWillPop: onBackPress,
        child: buildScreen(context),
      );
    else
      return Scaffold(
//          appBar: GradientAppBar(
//            title: new Text(widget.chatRoomName),
//            backgroundColorStart: Theme.of(context).primaryColor,
//            backgroundColorEnd: Colors.white70,
//          ),
//          appBar: GradientAppBar(
//            title: new Text(widget.chatRoomName != null ? widget.chatRoomName : this.chatRoomName != null ? this.chatRoomName : ""),
//            backgroundColorStart: Theme.of(context).primaryColor,
//            backgroundColorEnd: Colors.white70,
//          ),
          body: buildScreen(context),
      );//buildScreen(context),

//          CustomScrollView(
//            slivers: <Widget>[
//              SliverAppBar(
////              title: Text("hello"),
//                expandedHeight: 60,
//                floating: false,
//                pinned: true,
//                flexibleSpace: FlexibleSpaceBar(
//                  title: Text(widget.chatRoomName,
//                      style: TextStyle(fontSize: 15.0)),
//                  centerTitle: true,
//                  collapseMode: CollapseMode.parallax,
//                  background: Container(
////                color: RED,
//                    constraints: BoxConstraints.expand(height: 100),
//                    child: Image.asset(
//                      'images/appbarimage.jpg',
//                      fit: BoxFit.cover,
//                    ),
//                  ),
//                ),
//                leading: new Container(),
//              ),
////          SliverList(
////            delegate: SliverChildBuilderDelegate(
////              (BuildContext context, int index) {
////                return getTab(_currentIndex);
////              },
////                childCount: 2,
////                semanticIndexOffset: 2,
////              ),
////
////            ),
//              SliverList(
//                delegate: SliverChildListDelegate([
//                  SizedBox(
//                    height: MediaQuery.of(context).size.height, // or something simular :)
//                    child:
//                    new Column(
//                      mainAxisSize: MainAxisSize.max,
//                      children: <Widget>[
//                        new Expanded(
//                          child: buildScreen(context),
//                        ),
//                      ],
//                    ),
//                  ),
//                ]),
//              )
//            ],
//          ),
//);
  }


}
