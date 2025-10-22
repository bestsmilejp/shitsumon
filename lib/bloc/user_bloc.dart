import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shitsumon/UI/config.dart';
import 'package:shitsumon/bloc/app_bloc.dart';
import 'package:shitsumon/models/user.dart';

class UsersBloc {
  static UsersBloc? _instance;
  final _user = BehaviorSubject<bool>();
  final _userslist =
  BehaviorSubject<List<UsersModel>>.seeded([]);

  ValueStream<List<UsersModel>> get subChatRooms =>
      _userslist.stream;
  ValueStream<List<UsersModel>> get user => _userslist.stream;

  static UsersBloc? getInstance() {
    if (_instance == null) {
      _instance = new UsersBloc();
      return _instance;
    } else
      return _instance;
  }

  createUser(uid, wkPushToken) async{
    var isDebug = false;
    assert(isDebug = true);

    await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'id': uid,
        'createdOn': DateTime.now(),
        'pushToken': wkPushToken,
        'debug': isDebug
      });
  }

  Future<QuerySnapshot> getPushToken(wkPushToken) async{
    return await FirebaseFirestore.instance
        .collection('users')
        .where('pushToken', isEqualTo: wkPushToken)
        .get();
  }
//
//  getUsers() async {
//    var empty = _userslist.value.length == 0;
//    try {
//      if (empty) AppBloc.getInstance().loading(true);
//
//      if (_userslist == null || _userslist.value.length == 0) {
//        final documents = await FirebaseFirestore.instance
//            .collection('users')
//            .get();
//        _userslist.sink.add(documents.docs
//            .map((doc) => UsersModel(
//            id: doc.id,
//            nickname: doc.data()['nickname'],
//            photoUrl: doc.data()['photoUrl']))
//            .toList());
//      }
//    } catch (e) {
//      AppBloc.getInstance().showError(e);
//    } finally {
//      if (empty) AppBloc.getInstance().loading(false);
//    }
//  }

  updatePushToken(currentUserId, pushToken) async {
    var prefs = await SharedPreferences.getInstance();
    var wk_pushToken = pushToken != null ? pushToken : prefs.getString(Config.prefsPushToken);

    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: currentUserId)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length != 0 && (documents[0]['pushToken'] == null || documents[0]['pushToken'].length == 0)) {
        await FirebaseFirestore.instance.collection('users').doc(currentUserId).update(
            {'pushToken': wk_pushToken,
              'updateOn': DateTime.now()});
        await prefs.setString('pushToken', pushToken);
        print("updatePushToken - pushToken : $pushToken");
      }
    } catch (e) {
      AppBloc.getInstance()!.showError(e);
    } finally {
    }
  }

//  clearPushToken(currentUserId) async {
//    try {
//      final QuerySnapshot result = await FirebaseFirestore.instance
//          .collection('users')
//          .where('id', isEqualTo: currentUserId)
//          .get();
//      final List<DocumentSnapshot> documents = result.docs;
//      if (documents.length != 0 && (documents[0]['pushToken'] != null || documents[0]['pushToken'].length > 0)) {
//        await FirebaseFirestore.instance.collection('users').doc(currentUserId).update(
//            {'pushToken': "",
//              'updateOn': DateTime.now()});
//      }
//    } catch (e) {
//      AppBloc.getInstance().showError(e);
//    } finally {
//    }
//  }

//  String getPhotUrl(String id){
////    print("_userslist.value.length${_userslist.value.length}");
//    for(var i = 0; i < _userslist.value.length; i++ ){
//      var temp = _userslist.value[i];
//      if(id == temp.id){
//        return temp.photoUrl;
//      }
//    }
//    return "";
//  }



  dispose() {
    _userslist.close();
    _user.close();
  }
}