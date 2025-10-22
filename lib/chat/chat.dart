import 'dart:async';
import 'dart:io';

//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shitsumon/UI/config.dart';
import 'package:shitsumon/bloc/app_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shitsumon/bloc/chat_bloc.dart';
import 'package:shitsumon/chat/ChatMessage.dart';

class Chat extends StatelessWidget {
  final String chatRoomId;
  final String currentUserId;
  final String chatRoomName;
  final DateTime? latestMsgTimestamp;
  String? groupId;

  Chat({Key? key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.chatRoomName,
    this.latestMsgTimestamp,
    this.groupId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Chat build 1 - this.chatRoomId: ${this.chatRoomId}");
    print("Chat build 1 - this.currentUserId: ${this.currentUserId}");
    print("Chat build 1 - this.chatRoomName: ${this.chatRoomName}");
    print("Chat build 1 - this.groupId: ${this.groupId}");

    return
      (this.groupId == null || this.groupId!.isEmpty) ?
      new Scaffold(
        appBar: AppBar(
            title: Text(chatRoomName, style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).primaryColor,
//            brightness: Brightness.light,

//            backgroundColorStart: Theme
//                .of(context)
//                .primaryColor,
//            backgroundColorEnd: Theme
//                .of(context)
//                .primaryColorDark,
            iconTheme: IconThemeData(color: Colors.white)
        ),
        body: ChatScreen(
          chatRoomId: chatRoomId,
          currentUserId: currentUserId,
        ),
      ) :
      new Scaffold(
          body: ChatScreen(
            chatRoomId: chatRoomId,
            currentUserId: currentUserId,
            groupId: groupId,
          )
      );
  }
}

class ChatScreen extends StatefulWidget {
  final String? chatRoomId;
  final String? currentUserId;
  final String? chatRoomName;
  final String? groupId;

  ChatScreen(
      {Key? key,
        required this.chatRoomId,
        this.currentUserId,
        this.chatRoomName,
        this.groupId})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(chatRoomId: chatRoomId, groupId: groupId);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  ChatScreenState(
      {Key? key, required this.chatRoomId, this.groupId, this.animationController});

//  final avatars = Map<String, DocumentSnapshot>();

  String? chatRoomId;
  String? id;
  String? groupId;
  String? currentUserId;

  var listMessage;
  SharedPreferences? prefs;

  File? imageFile;
  bool isLoading = false;
  bool? isShowSticker;
  String? imageUrl;
  final AnimationController? animationController;
  final TextEditingController? textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    isLoading = false;
    id = widget.currentUserId;
    isShowSticker = false;
    imageUrl = '';
//    ChatBloc.getInstance().getBlockUser(id);
    print("ChatScreenState - initState 1 - currentUserId: $currentUserId");
    if(currentUserId == null || currentUserId!.length == 0){
      setState((){
        getPrefs();
        print("ChatScreenState - initState 2 - currentUserId: $currentUserId");
        if(currentUserId == null || currentUserId!.length == 0)
          AppBloc.getInstance()!.login();
          getPrefs();
        print("ChatScreenState - initState 3 - currentUserId: $currentUserId");
      });

    }
    ChatBloc.getInstance()!.getChat(chatRoomId!, id!);
//    readLocal();
  }

  getPrefs() async{
    var prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString(Config.prefsId);
    print("ChatScreenState - getPrefs - currentUserId: $currentUserId");
    print("ChatScreenState - getPrefs - prefs.getString(Config.prefsId): ${prefs.getString(Config.prefsId)}");
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  @override
  void dispose() {
    if (ChatBloc.getInstance()!.chatsSub != null)
      ChatBloc.getInstance()!.chatsSub!.cancel();
    super.dispose();
  }


  void likeUnlikeMessage(id,unlike) {
    print(id);
    ChatBloc.getInstance()!.likeUnlike(widget.currentUserId, chatRoomId, id,unlike);
  }


  Future<bool> onBackPress() {
    if (isShowSticker!) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    print("ChatScreenState build");
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildListMessage(),
              // Input content
//              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
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
    );
  }

  Widget buildListMessage() {
//    ChatBloc.getInstance().blocklist;
    print("ChatScreenState - buildListMessage");
//    if(ModalRoute.of(context).isCurrent){
//      isLoading = true;
//    }
    return Flexible(
      child: StreamBuilder(
        stream: ChatBloc.getInstance()!.chats,
        builder: (context, snapshot) {
          print("ChatScreenState - buildListMessage - snapshot.data: ${snapshot.data}");
          if (snapshot.data == null || snapshot.data![chatRoomId] == null) {
            // print("ChatScreenState 2 - buildListMessage - snapshot.data: ${snapshot.data}");
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)));
          } else {
            // print("ChatScreenState 3 - buildListMessage - snapshot.data: ${snapshot.data}");
            print("ChatScreenState 3 - buildListMessage - groupId: ${this.groupId}");
//            if(this.groupId != null) updatePrefs();
            listMessage = snapshot.data![chatRoomId];
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => ChatMessage(
                  id: id!,
                  listMessage: listMessage,
                  likeUnlikeMessage: likeUnlikeMessage,
                  index: index,
                  document: snapshot.data![chatRoomId]![index]),
              itemCount: snapshot.data![chatRoomId]!.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

}

