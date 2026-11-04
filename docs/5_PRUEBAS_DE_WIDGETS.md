# 5. Pruebas de Widgets en Flutter

## Objetivo
Verificar que un componente visual de la interfaz de usuario (UI) presente la pantalla y los controles correctos para cada uno de los estados posibles: cargando (*loading*), vacío (*empty*), error (*error*), y con datos (*data*), inyectando el estado o dependencias sin necesidad de conectarse a una API real.

---

## Componente Evaluado: `TaskListPanel` (`lib/task_list_panel.dart`)

El widget recibe el estado de forma declarativa e inmutable:
- `loading`: Si es verdadero, despliega un `CircularProgressIndicator`.
- `errorMessage`: Si no es nulo, despliega el mensaje de error y, si se provee un callback `onRetry`, un botón `Retry`.
- `tasks`: Si la lista está vacía, muestra `"No tasks yet."`. Si contiene elementos, renderiza un `ListView` con `ListTile` para cada tarea.

### Implementación del botón de reintento (Ejercicio Práctico Sección 5):
```dart
if (errorMessage != null) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(errorMessage!),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('retry-button'),
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ],
    ),
  );
}
```

---

## Pruebas de Widget Automatizadas (`test/task_list_panel_test.dart`)

```dart
void main() {
  group('TaskListPanel widget tests (Section 5)', () {
    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TaskListPanel(loading: true, tasks: [])),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TaskListPanel(loading: false, tasks: [])),
      );
      expect(find.text('No tasks yet.'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TaskListPanel(loading: false, tasks: [], errorMessage: 'Could not load tasks.'),
        ),
      );
      expect(find.text('Could not load tasks.'), findsOneWidget);
    });

    testWidgets('shows task data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TaskListPanel(loading: false, tasks: ['Plan tests'])),
      );
      expect(find.text('Plan tests'), findsOneWidget);
    });

    // Ejercicio práctico (Sección 5):
    testWidgets('tapping retry button invokes callback exactly once', (tester) async {
      int retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListPanel(
              loading: false,
              tasks: const [],
              errorMessage: 'Could not load tasks.',
              onRetry: () {
                retryCount++;
              },
            ),
          ),
        ),
      );

      final retryFinder = find.byKey(const Key('retry-button'));
      expect(retryFinder, findsOneWidget);
      expect(retryCount, 0);

      // Tocar el botón de reintento
      await tester.tap(retryFinder);
      await tester.pump();

      // Verificar que el callback se invocó exactamente una vez
      expect(retryCount, 1);
    });
  });
}
```

---

## Comando de Ejecución
```bash
flutter test test/task_list_panel_test.dart
```
**Resultado:** 5/5 pruebas de widget aprobadas.
