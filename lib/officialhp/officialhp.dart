import 'dart:async';

import 'package:shitsumon/UI/labels.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';

class OfficialHpScreen extends StatefulWidget {
  OfficialHpScreen();

  @override
  _OfficialHpScreenState createState() => new _OfficialHpScreenState();
}

class _OfficialHpScreenState extends State<OfficialHpScreen> {

  bool isLoading = false;

  Widget icon = Container(
    margin: EdgeInsets.symmetric(horizontal: 1.0),
    color: Colors.white,
    height: 4.0,
    width: 4.0,
  );

  // final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    _launchURL();
    // isLoading = true;
    // if (Platform.isAndroid) {
    //   WebView.platform = SurfaceAndroidWebView();
    // }
  }

  void _initLoad(String value) {
    setState(() {
      isLoading = true;
    });
  }

  void _launchURL() async {
    if (!await launch(Strings.official_url)) throw '${Strings.official_url}にアクセスできませんでした';
  }

  void _handleLoad(String value) {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Strings.official_url: ${Strings.official_url}");
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TOIN",
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255,205,44, 1.0),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
                Text(
                  "community currency",
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255,205,44, 1.0),
                  ),
              ),
              ],
            ),
          ),
          // Column(
          //   children: <Widget>[
          //     Expanded(
          //       flex: 1,
          //       child: Container(
          //         padding: EdgeInsets.all(5.0),
          //         child: Text("TOIN")
          //         // WebView(
          //         //   initialUrl: Strings.official_url,
          //         //   javascriptMode: JavascriptMode.unrestricted,
          //         //   onPageStarted: _initLoad,
          //         //   onPageFinished: _handleLoad,
          //         //   onWebViewCreated: (WebViewController controller) async{
          //         //     controllerGlobal = controller;
          //         //   },
          //           // onWebViewCreated: (WebViewController webViewController) {
          //           //   _controller.complete(webViewController);
          //           // },
          //         // ),
          //       ),
          //     ),
          //   ],
          // ),

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
