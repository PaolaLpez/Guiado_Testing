# 7. Pruebas de Recorridos Completos de Usuario (End-to-End)

## Objetivo
Verificar los flujos críticos de usuario desde la interfaz de usuario de la app Flutter pasando por la lógica de estado y componentes hasta el retorno visual.

---

## Estrategia de Pruebas E2E

El proyecto incluye dos modalidades para este recorrido:
1. **Prueba End-to-End Rápida en WidgetTester (`test/app_journey_test.dart`):** Permite ejecutar el flujo completo en CI y en terminales locales sin requerir un emulador encendido mediante `flutter test`.
2. **Prueba de Integración Nativa (`integration_test/app_test.dart`):** Diseñada para ejecutarse con `flutter test integration_test` sobre emuladores o dispositivos físicos reales.

---

## Flujo 1: Inicio de Sesión y Creación de Tarea (Ejemplo del Documento)

```dart
testWidgets('user can sign in and create a task', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Ingreso de credenciales de prueba
  await tester.enterText(find.byKey(const Key('email-field')), 'tester@example.test');
  await tester.enterText(find.byKey(const Key('password-field')), 'local-test-password');
  await tester.tap(find.byKey(const Key('login-button')));
  await tester.pumpAndSettle();

  // Apertura de diálogo y creación de tarea
  await tester.tap(find.byKey(const Key('add-task-button')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('task-title-field')), 'Check release flow');
  await tester.tap(find.byKey(const Key('save-task-button')));
  await tester.pumpAndSettle();

  // Verificación de la tarea en la interfaz
  expect(find.text('Check release flow'), findsOneWidget);
});
```

---

## Flujo 2: Ejercicio Práctico (Sección 7)

> **Instrucción:** *Extender el recorrido para marcar la tarea como completada, cerrar sesión y verificar que reaparezca la pantalla de inicio de sesión.*

### Código de la Prueba Extendida (`test/app_journey_test.dart`):
```dart
testWidgets(
  'extended journey: mark complete, log out, and verify login screen appears',
  (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Iniciar sesión
    await tester.enterText(find.byKey(const Key('email-field')), 'tester@example.test');
    await tester.enterText(find.byKey(const Key('password-field')), 'local-test-password');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    // 2. Crear tarea
    await tester.tap(find.byKey(const Key('add-task-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('task-title-field')), 'Check release flow');
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();
    expect(find.text('Check release flow'), findsOneWidget);

    // 3. Ejercicio Práctico: Marcar la tarea como completada
    final completeButton = find.byKey(const Key('complete-task-button'));
    expect(completeButton, findsOneWidget);
    await tester.tap(completeButton);
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);

    // 4. Ejercicio Práctico: Cerrar sesión
    final logoutButton = find.byKey(const Key('logout-button'));
    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // 5. Ejercicio Práctico: Verificar que reaparezca la pantalla de Login
    expect(find.byKey(const Key('login-button')), findsOneWidget);
    expect(find.byKey(const Key('email-field')), findsOneWidget);
    expect(find.byKey(const Key('password-field')), findsOneWidget);
  },
);
```

---

## Ejecución y Resultado
```bash
flutter test test/app_journey_test.dart
```
**Resultado:** Ambos flujos ejecutados y aprobados al 100%.
