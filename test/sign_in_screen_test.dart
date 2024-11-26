import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_tech_app/views/screens/SignInScreen.dart';
import 'package:pro_tech_app/views/controller/SignInController.dart';
import 'package:pro_tech_app/views/admin/AdminHomePage.dart';
import 'package:pro_tech_app/views/screens/SignupScreen.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'mocks.mocks.dart';

// Setup mock classes for Firebase Core
class MockFirebaseCore extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  bool get isInitialized => true;

  @override
  FirebaseAppPlatform get defaultApp => MockFirebaseApp();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }
}

class MockFirebaseApp extends Mock implements FirebaseAppPlatform {
  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'AIzaSyC3jkNrx89FjYJssximwxCLb4POt-uKjiU',
        appId: '1:477376322198:android:d82e4b825b496c02bb80b7',
        messagingSenderId: '477376322198',
        projectId: 'pro-tech-app-29e61',
      );
}

// Mock Navigator Observer
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setupFirebaseCoreMocks();

  group('SignInScreen Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late SignInController mockController;
    late MockNavigatorObserver navigationObserver;

    setUpAll(() async {
      // Initialize Firebase
      await Firebase.initializeApp();
      mockFirebaseAuth = MockFirebaseAuth();

      // Set up mock instance
      TestDefaultFirebaseAuth._mockInstance = mockFirebaseAuth;
    });

    setUp(() {
      navigationObserver = MockNavigatorObserver();

      // Initialize controller after Firebase mock setup
      mockController = SignInController();
      Get.put(mockController);
    });

    tearDown(() {
      Get.reset();
    });

    Future<void> pumpSignInScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const SignInScreen(),
          navigatorObservers: [navigationObserver],
          getPages: [
            GetPage(name: '/signup', page: () => const SignupScreen()),
            GetPage(name: '/admin', page: () => const AdminHomePage()),
          ],
        ),
      );
      await tester.pump();
    }

    testWidgets('Renders all important widgets', (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Remember Me'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      final passwordField = find.byType(TextField).at(1);
      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
    });

    testWidgets('Remember Me checkbox toggle works',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);

      await tester.tap(checkbox);
      await tester.pump();
      expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    });

    testWidgets('Admin login navigation works', (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      // Set up mock response for admin login
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: 'admin123',
      )).thenAnswer((_) async => MockUserCredential());

      await tester.enterText(find.byType(TextField).first, 'admin@gmail.com');
      await tester.enterText(find.byType(TextField).last, 'admin123');

      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminHomePage), findsOneWidget);
    });

    testWidgets('Shows error on empty email for forgot password',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();

      expect(find.text('Please enter your email first'), findsOneWidget);
    });

    testWidgets('Shows error on invalid credentials',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      // Set up mock to throw error
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(
          code: 'invalid-credential', message: 'Invalid credentials'));

      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');

      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('Social login buttons render correctly',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      expect(find.byIcon(FontAwesomeIcons.google), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.facebookF), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('Or sign in with'), findsOneWidget);
    });

    testWidgets('Social login buttons are clickable',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      final socialButtons = [
        FontAwesomeIcons.google,
        FontAwesomeIcons.facebookF,
        Icons.person_outline,
      ];

      for (var icon in socialButtons) {
        final button = find.ancestor(
          of: find.byIcon(icon),
          matching: find.byType(GestureDetector),
        );
        expect(button, findsOneWidget);
        await tester.tap(button);
        await tester.pump();
      }
    });

    testWidgets('Navigation to SignUp screen works',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('Forgot password works with valid email',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      // Enter valid email
      await tester.enterText(find.byType(TextField).first, 'test@test.com');

      // Set up mock for password reset
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@test.com',
      )).thenAnswer((_) async {});

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Password reset email sent'), findsOneWidget);
    });

    testWidgets('Shows loading indicator during login',
        (WidgetTester tester) async {
      await pumpSignInScreen(tester);

      // Set up delayed mock response
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'wrongpassword',
      )).thenAnswer((_) => Future.delayed(
            const Duration(seconds: 1),
            () => MockUserCredential(),
          ));

      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, 'password');

      await tester.tap(find.text('LOGIN'));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete
      await tester.pumpAndSettle();
    });

    test('SignInController methods exist', () {
      expect(mockController.handleLogin, isA<Function>());
      expect(mockController.handlePasswordRecovery, isA<Function>());
      expect(mockController.signInWithGoogle, isA<Function>());
      expect(mockController.signInWithFacebook, isA<Function>());
      expect(mockController.signInAnonymously, isA<Function>());
    });
  });
}

// Mock FirebaseAuth for testing
class TestDefaultFirebaseAuth {
  static MockFirebaseAuth? _mockInstance;

  static MockFirebaseAuth get instance {
    return _mockInstance ?? MockFirebaseAuth();
  }
}

// Setup Firebase mocks
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up Firebase Core mock
  final platform = MockFirebasePlatform();
  FirebasePlatform.instance = platform;
}

class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  FirebaseAppPlatform get defaultApp => MockFirebaseApp();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }
}
