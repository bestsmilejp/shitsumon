//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shitsumon/providers/google_provider.dart';

class AppBloc {
  static AppBloc? _instance;
  final _user = BehaviorSubject<bool>();
  final _loading = BehaviorSubject<bool>();
  final _onError = BehaviorSubject<String>();
  GoogleProvider _googleClient = new GoogleProvider();
  ValueStream<bool> get user => _user.stream;

  ValueStream<String> get onError => _onError.stream;

  ValueStream<bool> get isLoading => _loading.stream;

  AppBloc._() {
    _googleClient.isSignedIn().then((value) => _user.sink.add(value));
  }

  static AppBloc? getInstance() {
    if (_instance == null) {
      _instance = new AppBloc._();

      return _instance;
    } else
      return _instance;
  }

  loading(bool status) {
    _loading.sink.add(status);
  }

  hideLoading() {
    _loading.sink.add(false);
  }

  login() async {
    // Pass all uncaught errors to Crashlytics.
//    FlutterError.onError = (FlutterErrorDetails details) {
////      Crashlytics.instance.onError(details);
//    };
    await _googleClient.useGoogleApi();
    _user.sink.add(_googleClient.currentUser() != null);
  }

  showError(detail, {error = "問題が発生しました。しばらく経ってから再度お試しください。エラーが何度も発生する場合は、アプリを一旦閉じて、再度、アプリを起動してください。それでも解決しない場合は、アンインストールし、再度インストールしてください。"}) {
    _onError.sink.add(error);
    hideLoading();
    print("showError - details: $detail");
    print("showError - error: $error");
  }

  showError2({error = "問題が発生しました。しばらく経ってから再度お試しください。"}) {
    _onError.sink.add(error);
    hideLoading();
  }

//  logout({String currentUserId}) async {
//    try {
//      loading(true);
//      await _googleClient.logout();
////      await EventProvider.db.deleteAllEvent();
//      var prefs = await SharedPreferences.getInstance();
//      await prefs.clear();
//      if(currentUserId != null && currentUserId.length > 0)
//        UsersBloc.getInstance().clearPushToken(currentUserId);
//      _user.sink.add(false);
//    } catch (e) {
//      AppBloc.getInstance().showError(e);
//    } finally {
//      loading(false);
//    }
//  }

  dispose() {
    _onError.close();
    _user.close();
    _loading.close();
  }
}
