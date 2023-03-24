

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,

      onBackground: onIosBackground,
      onForeground: onStart
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,autoStart: true 
      )
    );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if(service is AndroidServiceInstance){
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
     });

     service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
     });
  }

  service.on('stopService').listen((event) {
      service.stopSelf();
    });
  
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if(service is AndroidServiceInstance){
      if(await service.isForegroundService()){
        service.setForegroundNotificationInfo(
          title: "Raksha", 
          content: "You are protected"
        );
      }
    }

    print("Background is sucessful");
    service.invoke('update');

   });
}

@pragma('vm:entry-point')
FutureOr<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
