// import 'dart:io';
//
// import 'package:device_info/device_info.dart';
//
// class _DeviceInfo {
//   var os = '';
//   var osVersion = '';
//   var model = '';
//
//   _DeviceInfo({
//     this.os,
//     this.osVersion,
//     this.model,
//   });
// }
//
// Future<_DeviceInfo> _deviceName() async {
//   final deviceInfo = _DeviceInfo(
//     os: Platform.operatingSystem,
//   );
//   final deviceInfoPlugin = DeviceInfoPlugin();
//   if (Platform.isAndroid) {
//     final androidInfo = await deviceInfoPlugin.androidInfo;
//     deviceInfo.model = androidInfo.model;
//     // ignore: cascade_invocations
//     deviceInfo.osVersion = androidInfo.version.release;
//   } else if (Platform.isIOS) {
//     final iosInfo = await deviceInfoPlugin.iosInfo;
//     deviceInfo.model = iosInfo.name;
//     // ignore: cascade_invocations
//     deviceInfo.osVersion = iosInfo.systemVersion;
//   }
//
//   return deviceInfo;
// }