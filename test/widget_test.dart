// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:habit_tracking/firebase_options.dart';
import 'package:habit_tracking/main.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracking/logic/controllers/auth_controller.dart' as app;
import 'package:habit_tracking/data/services/firebase_service.dart' as svc;
import 'package:habit_tracking/data/models/habit_model.dart';
import 'package:habit_tracking/data/models/habit_progress_model.dart';

class _FakeAuthController extends app.AuthController {
  // Implement only what's used: authStateChanges stream and signOut()
  @override
  Stream<User?> get authStateChanges => Stream<User?>.value(null);

  @override
  Future<void> signOut() async {}

  // Unused in this test but must exist to satisfy type
  @override
  Future<UserCredential> signIn(String email, String password) =>
      Future<UserCredential>.error(UnimplementedError());

  @override
  Future<UserCredential> signUp(String email, String password) =>
      Future<UserCredential>.error(UnimplementedError());
}

class _FakeFirebaseService extends svc.FirebaseService {
  // Minimal stubs used by bindings/controllers during startup
  @override
  String get currentUserId => 'testUser';

  @override
  Stream<List<Habit>> habitsStream() => Stream<List<Habit>>.value(const []);

  @override
  Future<List<Habit>> getAllHabits() async => const [];

  @override
  Future<int> migrateExactFields() async => 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initializes and shows splash', (WidgetTester tester) async {
    // Initialize Firebase for tests
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Ensure clean Get container and inject fakes before app bindings run
    Get.reset();
    Get.put<app.AuthController>(_FakeAuthController(), permanent: true);
    Get.put<svc.FirebaseService>(_FakeFirebaseService(), permanent: true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // Verify splash renders brand name
    expect(find.text('Habitual'), findsWidgets);
  });
}
