import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Thêm import này
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import './views/utils/workmanager_helper.dart'
    if (dart.library.js) './views/utils/workmanager_web_stub.dart';
import 'views/Routes/AppRoutes.dart';
import 'views/utils/NotificationService.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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

      // Thêm cấu hình localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Vietnamese
        Locale('en', 'US'), // English
      ],
      locale: const Locale('vi', 'VN'), // Set default locale to Vietnamese

      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
    );
  }
}

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyC3jkNrx89FjYJssximwxCLb4POt-uKjiU",
    appId: "1:477376322198:android:d82e4b825b496c02bb80b7",
    messagingSenderId: "477376322198",
    projectId: "pro-tech-app-29e61",
    storageBucket: "pro-tech-app-29e61.appspot.com",
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDH-BItWvtlFlpP-G7ywZjCbJvdGiH5gkY",
      authDomain: "pro-tech-app-29e61.firebaseapp.com",
      projectId: "pro-tech-app-29e61",
      storageBucket: "pro-tech-app-29e61.appspot.com",
      messagingSenderId: "477376322198",
      appId: "1:477376322198:web:268ae152c2d705a7bb80b7");
}
