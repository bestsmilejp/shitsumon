import 'dart:async';
import 'dart:io';

import 'package:shitsumon/UI/labels.dart';
import 'package:flutter/material.dart';
import 'package:shitsumon/UI/size_config.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart';
import '../app.dart';

class EventScreen extends StatefulWidget {
  EventScreen();

  @override
  _EventScreenState createState() => new _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  bool isLoading = false;
  late final WebViewController controllerGlobal;

  Widget icon = Container(
    margin: EdgeInsets.symmetric(horizontal: 1.0),
    color: Colors.white,
    height: 4.0,
    width: 4.0,
  );

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    // isLoading = true;
    controllerGlobal = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _initLoad,
          onPageFinished: _handleLoad,
        ),
      )
      ..loadRequest(Uri.parse(Strings.event_url));
  }

  void _initLoad(String value) {
    setState(() {
      isLoading = true;
    });
  }

  void _handleLoad(String value) {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Strings.event_url: ${Strings.event_url}");
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: WebViewWidget(controller: controllerGlobal),
                ),
              ),
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

  Future<bool> onBackPress() async{
    if (await controllerGlobal!.canGoBack()) {
      controllerGlobal!.goBack();
    }
    return Future.value(false);
  }

}