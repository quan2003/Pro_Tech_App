// Tạo file mới test/mocks.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
])
void main() {}
