import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shitsumon/UI/labels.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shitsumon/bloc/app_bloc.dart';
import 'package:shitsumon/models/ChatRoom.dart';

class ChatBloc {
  static ChatBloc? _instance;
  final _chat = BehaviorSubject<bool>();
  final _chatRooms = BehaviorSubject<List<ChatRoom>>.seeded([]);

  final _chats =
  BehaviorSubject<Map<String, List<ChatModel>>>.seeded(Map());
  final _block = BehaviorSubject<List<String>>.seeded([]);

  StreamSubscription<QuerySnapshot>? chatsSub;

  ValueStream<dynamic> get chat => _chat.stream;

  ValueStream<List<ChatRoom>> get chatRooms => _chatRooms.stream;

  ValueStream<Map<String, List<ChatModel>>> get chats => _chats.stream;

  ValueStream<List<String>> get blocklist => _block.stream;

  StreamSubscription<DocumentSnapshot>? sub;
  StreamSubscription<DocumentSnapshot>? blockStream;

  static ChatBloc? getInstance() {
    if (_instance == null) {
      _instance = new ChatBloc();
      return _instance;
    } else
      return _instance;
  }

  getChatRooms(String? chatRoomId) async {
    print("Called getChatRooms - chatRoomId: $chatRoomId");
    var empty = _chatRooms.value.length == 0;
    try {
      if (empty) AppBloc.getInstance()!.loading(true);
      if (this.sub != null) {
        this.sub!.cancel();
      }

      final documents = await FirebaseFirestore.instance.collection('chats')
          .orderBy('order').get();

      _chatRooms.sink.add(documents.docs
          .map((d) => ChatRoom(
            id: d.id,
            name: d.data()['name'],
            latestMsgTimestamp: d.data()['latestMsgTimestamp']))
          .toList());

    } catch (e) {
      AppBloc.getInstance()!.showError(e);
    } finally {
      if (empty) AppBloc.getInstance()!.loading(false);
    }
  }


  CollectionReference getMessagesRef(chatRoomId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages');
  }

//  CollectionReference getBlockRef(id) {
//    return Firestore.instance.collection('report').where("id", isEqualTo: id);
//  }


//  reportUser(idFrom, id, String type) async {
//    try {
//      //duplication check
//      //If not exist, then register
//      var collection = await Firestore.instance
//          .collection('report')
//          .where("idFrom", isEqualTo: idFrom)
//          .where("id", isEqualTo: id)
//          .where("type", isEqualTo: Strings.report_type_block)
//          .getDocuments();
//      var list = collection.documents.toList();
//      if (list.length == 0) {
//        Firestore.instance
//            .collection('report')
//            .add({'idFrom': idFrom, 'id': id, 'type': type});
//      }
//    } catch (e) {
//      AppBloc.getInstance().showError(e);
//    }
//  }

  likeUnlike(currentUserId, chatRoomId, id,unlike) {
    getMessagesRef(chatRoomId).doc(id).update({
      'likes':unlike? FieldValue.arrayRemove(List.from([currentUserId])): FieldValue.arrayUnion(List.from([currentUserId]))
    });
  }

  getChat(String chatRoomId, String id) async {
//    getBlockUser(id);
    print("ChatBloc - getChat 1 - chatRoomId: $chatRoomId");
    print("ChatBloc - getChat 1 - id: $id");

    var empty = _chats.value.length == 0;
    try {
      if (empty) AppBloc.getInstance()!.loading(true);
      if (this.chatsSub != null) {
        this.chatsSub!.cancel();
      }
      var chats = _chats.value;
      this.chatsSub = getMessagesRef(chatRoomId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((data) {
        chats[chatRoomId] = data.docs
            .map((doc) => ChatModel(
            id: doc.id,
            content: doc['content'],
            likes: (doc.data() as Map) ['likes']??[],
            idFrom: doc['idFrom'],
            timestamp: doc['timestamp'],
            type: doc['type']))
            .toList();

        _chats.sink.add(chats);
        print("ChatBloc - getChat 2 - chats.values.length: ${chats.values.length}");
        // print("ChatBloc - getChat 2 - chats.values: ${chats.values}");
      });

      print("ChatBloc - getChat 3 - _chats.value.length: ${_chats.value.length}");
      // print("ChatBloc - getChat 3 - _chats.value: ${_chats.value}");
        } catch (e) {
      AppBloc.getInstance()!.showError(e);
    } finally {
      if (empty) AppBloc.getInstance()!.loading(false);
    }
  }

  getBlockUser(id) async {
    var empty = _block.value.length == 0;
    try {
      if (empty) AppBloc.getInstance()!.loading(true);

      if (id != null) {
        //*** Everytime refresh block but not sure how to do ***
        // I think this should be ok because this should be called when chat screen is open
        final documents = await FirebaseFirestore.instance
            .collection('report')
            .where("type", isEqualTo: Strings.report_type_block)
            .where("id", isEqualTo: id)
            .get();
        _block.sink.add(documents.docs
            .map((doc) => (doc.data()['idFrom'].toString()))
            .toList());
      }
    } catch (e) {
      AppBloc.getInstance()!.showError(e);
    } finally {
      if (empty) AppBloc.getInstance()!.loading(false);
    }
  }

  dispose() {
    _chat.close();
    _chatRooms.close();
    _block.close();
  }
}
