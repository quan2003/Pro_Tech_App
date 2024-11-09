import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import './views/utils/workmanager_helper.dart'
    if (dart.library.js) './views/utils/workmanager_web_stub.dart';
import 'views/Routes/AppRoutes.dart';
import 'views/utils/NotificationService.dart';
import 'views/utils/SettingsProvider.dart';

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

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: const MyApp(),
        ),
      );
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
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return GetMaterialApp(
          title: 'Pro-Tech',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.SPLASH_SCREEN,
          getPages: AppRoutes.routes,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', 'VN'),
            Locale('en', 'US'),
          ],
          locale: const Locale('vi', 'VN'),
          theme: _buildThemeData(settings, isDark: false),
          darkTheme: _buildThemeData(settings, isDark: true),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }

  ThemeData _buildThemeData(SettingsProvider settings, {required bool isDark}) {
    final baseTextColor = isDark ? Colors.white : Colors.black87;

    return ThemeData(
      primarySwatch: Colors.purple,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,

      // Card Theme
      cardTheme: CardTheme(
        color: isDark ? Colors.grey[850] : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: baseTextColor,
        ),
        titleTextStyle: TextStyle(
          color: baseTextColor,
          fontSize: 20 * settings.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 32 * settings.fontSize,
          fontWeight: FontWeight.bold,
          color: baseTextColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28 * settings.fontSize,
          fontWeight: FontWeight.bold,
          color: baseTextColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24 * settings.fontSize,
          fontWeight: FontWeight.bold,
          color: baseTextColor,
        ),

        // Headline styles
        headlineMedium: TextStyle(
          fontSize: 20 * settings.fontSize,
          fontWeight: FontWeight.w600,
          color: baseTextColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18 * settings.fontSize,
          fontWeight: FontWeight.w600,
          color: baseTextColor,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 20 * settings.fontSize,
          fontWeight: FontWeight.bold,
          color: baseTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18 * settings.fontSize,
          fontWeight: FontWeight.bold,
          color: baseTextColor,
        ),
        titleSmall: TextStyle(
          fontSize: 16 * settings.fontSize,
          fontWeight: FontWeight.bold,
          color: baseTextColor,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16 * settings.fontSize,
          color: baseTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * settings.fontSize,
          color: baseTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * settings.fontSize,
          color: baseTextColor,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: baseTextColor,
        size: 24 * settings.fontSize,
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: 16 * settings.fontSize,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          fontSize: 16 * settings.fontSize,
          color: baseTextColor,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14 * settings.fontSize,
          color: baseTextColor.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: baseTextColor.withOpacity(0.1),
        thickness: 1,
        space: 1,
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
    appId: "1:477376322198:web:268ae152c2d705a7bb80b7",
  );
}
