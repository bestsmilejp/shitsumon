// import 'package:flutter/gestures.dart';
// // import 'package:platform_detect/platform_detect.dart';
//
// import '../app.dart';
//
// class PlatformViewVerticalGestureRecognizer
//     extends HorizontalDragGestureRecognizer {
//   PlatformViewVerticalGestureRecognizer({PointerDeviceKind kind})
//       : super(supportedDevices: <PointerDeviceKind>{kind});
//
//   Offset _dragDistance = Offset.zero;
//
//   // final Future<WebViewController> _webViewControllerFuture;
//
//
//
//   @override
//   void addPointer(PointerEvent event) {
//     // if(browser.isChrome){
//     //   print("browser is chrome");
//     //
//     // }else if(browser.isSafari){
//     //   print("browser is Safari");
//     //
//     // }
//     // print("browser: $browser");
//     startTrackingPointer(event.pointer);
//   }
//
//   @override
//   void handleEvent(PointerEvent event) {
//     _dragDistance = _dragDistance + event.delta;
//     // print("event : $event");
//
//     if (event is PointerMoveEvent) {
//       final double dy = _dragDistance.dy.abs();
//       final double dx = _dragDistance.dx.abs();
//
//       if (dy > dx && dy > kTouchSlop) {
//         // vertical drag - accept
//         resolve(GestureDisposition.accepted);
//         _dragDistance = Offset.zero;
//       } else if (dx > kTouchSlop && dx > dy) {
//         // horizontal drag - stop tracking
//         stopTrackingPointer(event.pointer);
//         _dragDistance = Offset.zero;
//         goBack();
//       }
//     }
//   }
//
//   void goBack() async{
//     if(await controllerGlobal.canGoBack()){
//       controllerGlobal.goBack();
//     }
//   }
//
//   @override
//   String get debugDescription => 'horizontal drag (platform view)';
//
//   @override
//   void didStopTrackingLastPointer(int pointer) {}
// }
// //
