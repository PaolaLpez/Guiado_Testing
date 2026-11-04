import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can sign in and create a task', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email-field')), 'tester@example.test');
    await tester.enterText(find.byKey(const Key('password-field')), 'local-test-password');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-task-button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('task-title-field')), 'Check release flow');
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('Check release flow'), findsOneWidget);
  });

  testWidgets(
    'extended journey: mark complete, log out, and verify login screen appears (Section 7 Practice Exercise)',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await tester.enterText(find.byKey(const Key('email-field')), 'tester@example.test');
      await tester.enterText(find.byKey(const Key('password-field')), 'local-test-password');
      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      // Add task
      await tester.tap(find.byKey(const Key('add-task-button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('task-title-field')), 'Check release flow');
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();
      expect(find.text('Check release flow'), findsOneWidget);

      // Practice exercise: mark the task complete
      final completeButton = find.byKey(const Key('complete-task-button'));
      expect(completeButton, findsOneWidget);
      await tester.tap(completeButton);
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsOneWidget);

      // Practice exercise: log out
      final logoutButton = find.byKey(const Key('logout-button'));
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Practice exercise: verify that the login screen appears
      expect(find.byKey(const Key('login-button')), findsOneWidget);
    },
  );
}
