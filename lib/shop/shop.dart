import 'package:shitsumon/UI/labels.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../app.dart';

class ShopScreen extends StatefulWidget {
  ShopScreen();

  @override
  _ShopScreenState createState() => new _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {

  bool isLoading = false;

  Widget icon = Container(
    margin: EdgeInsets.symmetric(horizontal: 1.0),
    color: Colors.white,
    height: 4.0,
    width: 4.0,
  );

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
      ..loadRequest(Uri.parse(Strings.shop_url));
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
    print("Strings.shop_url: ${Strings.shop_url}");
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await onBackPress();
        }
      },
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: controllerGlobal != null
                    ? WebViewWidget(controller: controllerGlobal!)
                    : Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
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
    if (controllerGlobal != null && await controllerGlobal!.canGoBack()) {
      controllerGlobal!.goBack();
    }
    return Future.value(false);
  }

}
