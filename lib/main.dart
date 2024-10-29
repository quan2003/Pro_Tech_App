import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

// Conditional import for Workmanager
import './views/utils/workmanager_helper.dart'
    if (dart.library.js) './views/utils/workmanager_web_stub.dart';
import 'views/Routes/AppRoutes.dart';
import 'views/utils/NotificationService.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // ignore: avoid_print
  print('Handling a background message: ${message.messageId}');
  await NotificationService().handleBackgroundMessage(message);
}

Future<void> _ensureFirebaseInitialized() async {
  if (!Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options:
          kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.android,
    );
  }
}

// final HealthService healthService = HealthService();

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await _ensureFirebaseInitialized();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      print('Background message handler set up successfully');

      if (!kIsWeb) {
        await Firebase.initializeApp();
        await NotificationService().initNotification();
        await initializeWorkmanager();
        await registerPeriodicTasks();
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);

        // Initialize HealthService
        // await healthService.initialize();
        // bool authorized = await healthService.requestAuthorization();
        // if (authorized) {
        //   print('Health data access authorized');
        // } else {
        //   print('Health data access not authorized');
        // }
      }

      runApp(const MyApp());
    } catch (error) {
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Có lỗi xảy ra khi khởi động ứng dụng: $error'),
          ),
        ),
      ));
    }
  }, (error, stackTrace) {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pro-Tech',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.SPLASH_SCREEN,
      getPages: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
    );
  }
}

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDm-LnWxMTncU4nvMhdGFyT0Qh2SSjwgIg',
    appId: '1:989890578847:android:8c0ab0b820dbdbfa9d95aa',
    messagingSenderId: '989890578847',
    projectId: 'signin-example-b56ee',
    storageBucket: 'signin-example-b56ee.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDm-LnWxMTncU4nvMhdGFyT0Qh2SSjwgIg',
    appId: '1:989890578847:web:903a936a3b2278ed9d95aa',
    messagingSenderId: '989890578847',
    projectId: 'signin-example-b56ee',
    storageBucket: 'signin-example-b56ee.appspot.com',
    authDomain: 'signin-example-b56ee.firebaseapp.com',
    measurementId: 'G-6C63FNQH88',
  );
}
