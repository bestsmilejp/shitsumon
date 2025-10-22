import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shitsumon/UI/config.dart';
import 'package:shitsumon/UI/labels.dart';
import 'package:shitsumon/UI/size_config.dart';
import 'package:shitsumon/models/ChatRoom.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart' as launcher;

class ChatMessage extends StatelessWidget {
  final ChatModel document;
  final List? blockList;
  final String id;
  final int index;
  final Animation? animation;
  final Function? showDeleteDialog;
  final Function? likeUnlikeMessage;
  final Function? showReportDialog;
  final Function? copyClipboard;
//  final Function getAvatar;
  final listMessage;

  ChatMessage(
      {required this.document,
      this.blockList,
      required this.id,
      required this.index,
      this.animation,
      this.showDeleteDialog,
      this.likeUnlikeMessage,
      this.showReportDialog,
      this.copyClipboard,
//      @required this.getAvatar,
      required this.listMessage}) {}
//  final _imageSaver = ImageSaver();

//  Future<void> saveNetworkImage(url) async {
//    print(url);
//    Response response = await get(url);
//    print('dc');
//    final res = await _imageSaver.saveImage(imageBytes: response.bodyBytes);
//    print(res);
//  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isDateChanged(int index) {
    if ((listMessage != null)) {
      if (index == listMessage.length - 1) {
        return true;
      }
      if (index < listMessage.length - 1) {
        if(listMessage[index + 1].timestamp == "" || listMessage[index].timestamp == "")
          return false;
        final prevDate = DateFormat('yyyy/MM/dd').format(
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(listMessage[index + 1].timestamp)));
        final date = DateFormat('yyyy/MM/dd').format(
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(listMessage[index].timestamp)));
        return prevDate != date;
      }
      return false;
    } else {
      return false;
    }
  }

  bool isFirstMessageLeft(int index, String id) {
    if ((listMessage != null &&
        index < listMessage.length - 1 &&
        listMessage[index].idFrom == id &&
        listMessage[index + 1].idFrom != id)) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

//  Widget renderAvatar(avtar, context) {
//    return avtar != null
//        ? GestureDetector(
//            child: Row(
//              children: <Widget>[
//                Material(
////                  child: CachedNetworkImage(
////                    placeholder: (context, url) => Container(
////                      child: CircularProgressIndicator(
////                        strokeWidth: 1.0,
////                        valueColor: AlwaysStoppedAnimation<Color>(
////                            Theme.of(context).primaryColor),
////                      ),
////                      width: 35.0,
////                      height: 35.0,
////                      padding: EdgeInsets.all(10.0),
////                    ),
////                    imageUrl: avtar['photoUrl'],
////                    width: 35.0,
////                    height: 35.0,
////                    fit: BoxFit.cover,
////                  ),
//                  borderRadius: BorderRadius.all(
//                    Radius.circular(18.0),
//                  ),
//                  clipBehavior: Clip.hardEdge,
//                ),
//              ],
//            ),
//          )
//        : Container(width: 35.0);
//  }
  bool _isLink(String input) {
    return Strings.matcher.hasMatch(input);
  }

//  final matcher = new RegExp(
//      r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=!]*)");
//        r"(http(s)?://([\w-]+\.)+[\w-]+(/[\w- ./?%&=~]*)?)");

  List<String> getPosURL(String input){
//    startPos = matcher.allMatches(input);

    int startPos = 0;
    int endPos = 0;
    int totalEndPos = 0;
    List<String> contents = [];
    String workInput = input;
    final allmatches = Strings.matcher.allMatches(document.content??"");
    allmatches.forEach((element) {
      String? temp = element.group(0);
      startPos = workInput.indexOf(temp!);
      endPos = workInput.indexOf(temp) + temp.length;
      totalEndPos = totalEndPos + endPos;
      contents.add(workInput.substring(0, startPos));
      contents.add(temp);
      if(endPos < workInput.length)
        workInput = workInput.substring(endPos, workInput.length);
    });

    //have to consider last match context and till the last char
    if(totalEndPos < input.length)
      contents.add(input.substring(totalEndPos, input.length));

    return contents;
  }

  Widget buildLeftMessage(BuildContext context) {
    final _style = Theme.of(context).textTheme.bodyLarge;
    final words = getPosURL(document.content??"");
    List<TextSpan> span = [];
    words.forEach((word) {
      span.add(_isLink(word)
          ? new LinkTextSpan(
          text: '$word',
          url: word,
          style: _style!.copyWith(color: Colors.blue))
          : new TextSpan(text: '$word', style: _style?.copyWith(color: Colors.black54)));
    });
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
//              avtar != null
//                  ? GestureDetector(
//                      child: renderAvatar(avtar, context),
//                      onLongPress: () => showReportDialog(document.idFrom, id),
//                    )
//                  : renderAvatar(avtar, context),
              document.type == 0
                  ? GestureDetector(
                      child: Row(children: <Widget>[
                        Stack(children: <Widget>[
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: SizeConfig.width(85),
                                child:
                                Row(
//                                  mainAxisAlignment:
//                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
//                                    Text(
//                                      avtar != null ? avtar['nickname'] : '',
//                                      style: TextStyle(
//                                          color: Colors.black54, fontSize: 10),
//                                    ),
                                    Text(
                                        listMessage[index].timestamp != "" ?
                                        DateFormat('hh:mm a').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(listMessage[index]
                                                    .timestamp))) : "",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 10))
                                  ],
                                ),
                              ),
                              Container(
                                  child:
                                    span.length > 0?
                                    RichText(
                                      text: TextSpan(
                                        text: '',
                                        children: span),
                                    )
                                    :
                                    SelectableText(
                                      document.content??"",
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                width: SizeConfig.width(90),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.only(left: 10.0, bottom: 20),
                              ),
                            ],
                          ),
                          Positioned(
                            child: Row(
                              children: [
                                Container(
                                  child: IconButton(
                                    icon: new Icon(
                                      document.likes != null &&
                                              document.likes!.contains(id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                    ),
                                    iconSize: 10,
                                    onPressed: () => likeUnlikeMessage!(document.id,
                                        document.likes != null && document.likes!.contains(id)),
                                    color: document.likes != null &&
                                            document.likes!.contains(id)
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                  width: 30,
                                ),
                                Text(
                                  document.likes != null &&
                                          document.likes!.length > 0
                                      ? document.likes!.length.toString()
                                      : '',
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            bottom: -15,
                            left: 10,
                          )
                        ])
                      ]),
//                      onLongPress: () => copyClipboard(document.content),
                      onDoubleTap: () => likeUnlikeMessage!(
                          document.id,
                          document.likes != null &&
                              document.likes!.contains(id)),
                    )
                  : // Image
                  GestureDetector(
                      child: Stack(
                        children: [
                          Container(
                            child: Material(
//                              child: CachedNetworkImage(
//                                placeholder: (context, url) => Container(
//                                  child: CircularProgressIndicator(
//                                    valueColor: AlwaysStoppedAnimation<Color>(
//                                        Theme.of(context).secondaryHeaderColor),
//                                  ),
//                                  width: 200.0,
//                                  height: 200.0,
//                                  padding: EdgeInsets.all(70.0),
//                                  decoration: BoxDecoration(
//                                    color: Colors.black54,
//                                    borderRadius: BorderRadius.all(
//                                      Radius.circular(8.0),
//                                    ),
//                                  ),
//                                ),
//                                errorWidget: (context, url, o) => Material(
//                                  child: Image.asset(
//                                    'images/img_not_available.jpeg',
//                                    width: 200.0,
//                                    height: 200.0,
//                                    fit: BoxFit.cover,
//                                  ),
//                                  borderRadius: BorderRadius.all(
//                                    Radius.circular(8.0),
//                                  ),
//                                  clipBehavior: Clip.hardEdge,
//                                ),
//                                imageUrl: document.content,
//                                width: 200.0,
//                                height: 200.0,
//                                fit: BoxFit.cover,
//                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            margin: EdgeInsets.only(left: 10.0,bottom: 20),
                          ),
                          Positioned(
                            child:Row(
                              children: [
//                                Container(
//                                  margin: EdgeInsets.only(bottom: 5),
//                                  child: IconButton(
//                                    icon: new Icon(
//                                      Icons.cloud_download,
//                                      size: 20,
//                                    ),
//                                    iconSize: 10,
//                                    onPressed: () =>
//                                        saveNetworkImage(document.content),
//                                    color: Color.fromRGBO(179, 167, 239, 1),
//                                  ),
//                                  width: 30,
//                                  height: 30,
//                                ),
                                Container(
                                  child: IconButton(
                                    icon: new Icon(
                                      document.likes != null &&
                                              document.likes!.contains(id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                    ),
                                    iconSize: 10,
                                    onPressed:() => likeUnlikeMessage!(document.id,
                                        document.likes != null && document.likes!.contains(id)),
                                    color: document.likes != null &&
                                            document.likes!.contains(id)
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                  width: 30,
                                ),
                                Text(
                                  document.likes != null &&
                                          document.likes!.length > 0
                                      ? document.likes!.length.toString()
                                      : '',
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            bottom: -15,
                            right: 10,
                          )
                        ],
                      ),
//                      onLongPress: () => copyClipboard(document.content),
                      onDoubleTap: () => likeUnlikeMessage!(
                          document.id,
                          document.likes != null &&
                              document.likes!.contains(id)),
                    ),
            ],
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      margin: EdgeInsets.only(bottom: 10.0),
    );
  }

  int? getTimestamp() {
    var isFirstMessage = index == listMessage.length - 1;
    int? timestamp = 0;
    if (index == 0 && listMessage.length > 1) {
      timestamp = int.parse(listMessage[index + 1].timestamp);
    } else if (isFirstMessage) {
      timestamp = null;
    } else if (listMessage.length == 1) {
      timestamp = null;
    }
    print(index);
    print(timestamp);
    return timestamp;
  }

//  Widget buildRightMessage(BuildContext context) {
//    return Row(
//      children: <Widget>[
//        document.type == 0
//            // Text
//            ? GestureDetector(
//                child: Row(
//                  children: <Widget>[
//                    Stack(
//                      children: <Widget>[
//                        Column(
//                          children: [
////                            Container(
////                              margin: EdgeInsets.only(top: 10),
////                              width: SizeConfig.width(70),
////                              child: Row(
////                                mainAxisAlignment:
////                                    MainAxisAlignment.spaceBetween,
////                                children: <Widget>[
////                                  Text(
////                                    avtar != null ? avtar['nickname'] : '',
////                                    style: TextStyle(
////                                        color: Colors.black54, fontSize: 10),
////                                  ),
////                                  Text(
////                                      DateFormat('hh:mm a').format(DateTime
////                                          .fromMillisecondsSinceEpoch(int.parse(
////                                              listMessage[index].timestamp))),
////                                      style: TextStyle(
////                                          color: Colors.black54, fontSize: 10))
////                                ],
////                              ),
////                            ),
//                            Container(
//                              child: SelectableText(
//                                document.content,
//                                style: TextStyle(color: Theme.of(context).primaryColor),
//                              ),
//                              padding:
//                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
//                              width: SizeConfig.width(75),
//                              decoration: BoxDecoration(
//                                  color: Theme.of(context).secondaryHeaderColor,
//                                  borderRadius: BorderRadius.circular(8.0)),
//                              margin: EdgeInsets.only(
//                                  bottom:
//                                      isLastMessageRight(index) ? 20.0 : 20.0,
//                                  right: 10.0),
//                            ),
//                          ],
//                        ),
//                        Positioned(
//                          child: Row(
//                            children: [
//                              Container(
//                                child: IconButton(
//                                  icon: new Icon(
//                                    document.likes != null &&
//                                            document.likes.contains(id)
//                                        ? Icons.favorite
//                                        : Icons.favorite_border,
//                                    size: 20,
//                                  ),
//                                  iconSize: 10,
//                                  onPressed: () => likeUnlikeMessage(document.id,
//                                      document.likes != null && document.likes.contains(id)),
//                                  color: document.likes != null &&
//                                          document.likes.contains(id)
//                                      ? Theme.of(context).primaryColor
//                                      : Colors.grey,
//                                ),
//                                width: 30,
//                              ),
//                              Text(
//                                document.likes != null &&
//                                        document.likes.length > 0
//                                    ? document.likes.length.toString()
//                                    : '',
//                                style: TextStyle(fontSize: 12),
//                              )
//                            ],
//                          ),
//                          bottom: -15,
//                          left: 0,
//                        )
//                      ],
//                    ),
////                    renderAvatar(avtar, context),
//                  ],
//                ),
//                onHorizontalDragEnd: (details) {
//                  showDeleteDialog(document.id, getTimestamp());
//                },
//                onDoubleTap: () => likeUnlikeMessage(document.id,
//                    document.likes != null && document.likes.contains(id)),
////                onLongPress: () => copyClipboard(document.content),
//              )
//            : // Image
//            GestureDetector(
//                child: Container(child: Stack(
////                  overflow: Overflow.visible,
//                  children: <Widget>[
////                    Column(
////                      children: [
////                        Container(
////                          margin: EdgeInsets.only(top: 10),
////                          width: SizeConfig.width(50),
////                          child: Row(
////                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                            children: <Widget>[
////                              Text(
////                                avtar != null ? avtar['nickname'] : '',
////                                style: TextStyle(
////                                    color: Colors.black54, fontSize: 10),
////                              ),
////                              Text(
////                                  DateFormat('hh:mm a').format(
////                                      DateTime.fromMillisecondsSinceEpoch(
////                                          int.parse(
////                                              listMessage[index].timestamp))),
////                                  style: TextStyle(
////                                      color: Colors.black54, fontSize: 10))
////                            ],
////                          ),
////                        ),
////                        Container(
////                          child: Material(
////                            child: CachedNetworkImage(
////                              placeholder: (context, url) => Container(
////                                child: CircularProgressIndicator(
////                                  valueColor: AlwaysStoppedAnimation<Color>(
////                                      Theme.of(context).secondaryHeaderColor),
////                                ),
////                                width: 200.0,
////                                height: 200.0,
////                                padding: EdgeInsets.all(70.0),
////                                decoration: BoxDecoration(
////                                  color: Colors.black54,
////                                  borderRadius: BorderRadius.all(
////                                    Radius.circular(8.0),
////                                  ),
////                                ),
////                              ),
////                              errorWidget: (context, url, o) => Material(
////                                child: Image.asset(
////                                  'images/img_not_available.jpeg',
////                                  width: 200.0,
////                                  height: 200.0,
////                                  fit: BoxFit.cover,
////                                ),
////                                borderRadius: BorderRadius.all(
////                                  Radius.circular(8.0),
////                                ),
////                                clipBehavior: Clip.hardEdge,
////                              ),
////                              imageUrl: document.content,
////                              width: 200.0,
////                              height: 200.0,
////                              fit: BoxFit.cover,
////                            ),
////                            borderRadius:
////                            BorderRadius.all(Radius.circular(8.0)),
////                            clipBehavior: Clip.hardEdge,
////                          ),
////                          margin: EdgeInsets.only(
////                          bottom:  20.0,
////                              right: 10.0),
////                        ),
////                      ],
////                    ),
//                    Positioned(
//                      child: Row(
//                        children: [
////                          Container(
////                            margin: EdgeInsets.only(bottom: 5),
////                            child: IconButton(
////                              icon: new Icon(
////                                Icons.cloud_download,
////                                size: 20,
////                              ),
////                              iconSize: 10,
////                              onPressed: () =>
////                                  saveNetworkImage(document.content),
////                              color:  Color.fromRGBO(179, 167, 239, 1),
////                            ),
////                            width: 30,
////                          ),
//                          Container(
//                            child: IconButton(
//                              icon: new Icon(
//                                document.likes != null &&
//                                    document.likes.contains(id)
//                                    ? Icons.favorite
//                                    : Icons.favorite_border,
//                                size: 20,
//                              ),
//                              iconSize: 10,
//                              onPressed: () => likeUnlikeMessage(document.id,
//                                  document.likes != null && document.likes.contains(id)),
//                              color: document.likes != null &&
//                                  document.likes.contains(id)
//                                  ? Theme.of(context).primaryColor
//                                  : Colors.grey,
//                            ),
//                            width: 30,
////                            height: 20,
//                          ),
//                          Text(
//                            document.likes != null && document.likes.length > 0
//                                ? document.likes.length.toString()
//                                : ' ',
//                            style: TextStyle(fontSize: 12),
//                          )
//                        ],
//                      ),
//                      bottom: -20,
//                      left: 0,
//                    ),
//                  ],
//                ),),
//
//                onDoubleTap: () => likeUnlikeMessage(document.id,
//                    document.likes != null && document.likes.contains(id)),
//                onLongPress: () =>
//                    showDeleteDialog(document.id, getTimestamp()),
//                onHorizontalDragEnd: (detail) =>
//                    showDeleteDialog(document.id, getTimestamp()),
//              ),
//      ],
//      mainAxisAlignment: MainAxisAlignment.end,
//    );
//  }

  Widget buildMessage(BuildContext context) {
    return buildLeftMessage(context);
//    final avtar = getAvatar(document.idFrom);
//    if (document.idFrom == id) {
//      // Right (my message)
//      return buildLeftMessage(context);
//    } else {
//      // Left (peer message)
//      return buildLeftMessage(context);
//    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        isDateChanged(index)
            ? Card(
                color: Theme.of(context).primaryColorDark,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    listMessage[index].timestamp != "" ?
                    DateFormat('yyyy/MM/dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(listMessage[index].timestamp))): "",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              )
            : Container(),
        buildMessage(context)
      ],
    );
  }

}
class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle? style, String? url, String? text})
      : super(
      style: style,
      text: text ?? url,
      recognizer: new TapGestureRecognizer()
        ..onTap = () => launcher.launch(url??""));
}