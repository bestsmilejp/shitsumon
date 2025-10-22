import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:google_sign_in/google_sign_in.dart'
//    show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;
//import 'package:googleapis/calendar/v3.dart'
//    show CalendarApi, CalendarListEntry, Event, EventAttendee, Events;
//import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart'
    show BaseRequest, BaseClient, Response, StreamedResponse;
import 'package:http/http.dart';
import 'package:shitsumon/bloc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shitsumon/UI/config.dart';
import 'package:shitsumon/UI/labels.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//class GoogleHttpClient extends BaseClient {
//  Map<String, String> _headers;
//  Client _client;
//
//  GoogleHttpClient(this._headers, this._client) : super();
//
//  @override
//  Future<StreamedResponse> send(BaseRequest request) {
//    request.headers.addAll(_headers);
//    return _client.send(request);
//  }
//
//  @override
//  Future<Response> head(Object url, {Map<String, String> headers}) {
//    headers.addAll(_headers);
//    return _client.head(url, headers: headers);
//  }
//}

class GoogleProvider {
  User? firebaseUser;

  LoginUser? _loginUser;
  GoogleProvider() {
    _loginUser = new LoginUser();
  }

  Future<bool> isSignedIn() async {
    return firebaseUser!=null ? (firebaseUser?.uid != null ? true : false) : false;
  }

  logout() async {
//    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    var prefs = await SharedPreferences.getInstance();
    print("logout: prefs.getString('pushToken'): ${prefs.getString(Config.prefsPushToken)}");
  }

  currentUser() => _loginUser?.userId !=null? _loginUser?.userId  : "";


  useGoogleApi() async {
    try {
      print("Called useGoogleApi");

      var prefs = await SharedPreferences.getInstance();
      var wkPushToken = prefs.getString(Config.prefsPushToken);
      print("Called useGoogleApi - wkPushToken: $wkPushToken");
      if(wkPushToken == null){
        FirebaseMessaging.instance.getToken().then((pushToken) async{
          wkPushToken = pushToken;
        });
      }

      if(_loginUser?.userId == null){
        if(firebaseUser == null || firebaseUser?.uid == null) {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          firebaseUser = (await _auth.signInAnonymously()).user;
          _loginUser?.userId = firebaseUser?.uid??"";


          if (firebaseUser != null) {
            //If same pushToken exist with different ID, clear the token
            final QuerySnapshot resultToken = await UsersBloc.getInstance()!.getPushToken(wkPushToken);

            final List<DocumentSnapshot> documentToken = resultToken.docs;

            if (documentToken.length == 0) {
              // Update data to server if new user
              await UsersBloc.getInstance()!.createUser(firebaseUser!.uid, wkPushToken);
            }

          }
        }
        await prefs.setString(Config.prefsId, _loginUser?.userId??"");
        await prefs.setString(Config.prefsPushToken, wkPushToken??"");

        print("useGoogleApi - _loginUser.userId: ${_loginUser?.userId}");
        print("useGoogleApi - prefs.getString(Config.prefsId): ${prefs.getString(Config.prefsId)}");
      }

    }catch(e){
      print("useGoogleApi - eception: $e");
    }
  }
}

class LoginUser {
  String? userId;
  LoginUser({this.userId});
}
