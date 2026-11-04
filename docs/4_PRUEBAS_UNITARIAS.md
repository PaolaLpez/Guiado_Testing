# 4. Pruebas Unitarias en Aislamiento

## Objetivo
Verificar funciones o clases pequeñas de manera rápida, determinista y precisa cada vez que cambien las reglas de negocio o la lógica de serialización/deserialización, sin depender de la red ni de una base de datos real.

---

## 1. Pruebas del Backend (Node.js + Jest)

El backend valida que el título de una tarea sea una cadena válida entre 1 y 120 caracteres luego de eliminar espacios en los extremos (`.trim()`).

### Código de la función: `backend/src/tasks/validation.js`
```javascript
'use strict';

function validateTitle(value) {
  if (typeof value !== 'string') {
    throw new TypeError('Enter a valid title.');
  }
  const title = value.trim();
  if (title.length < 1 || title.length > 120) {
    throw new TypeError('Enter a valid title.');
  }
  return title;
}

module.exports = { validateTitle };
```

### Pruebas Unitarias en Jest: `backend/test/validation.test.js`
Incluye los ejemplos del documento y los ejercicios prácticos solicitados:
- Recorte de espacios de un título válido.
- Rechazo de títulos en blanco.
- Rechazo de títulos con más de 120 caracteres.
- **Ejercicio práctico:** Aceptación de un título con exactamente 120 caracteres (límite máximo permitido).
- **Ejercicio práctico:** Rechazo de tipos de datos no válidos (números, objetos, null, undefined).

---

## 2. Pruebas del Modelo en Flutter/Dart (`flutter_test`)

El modelo `Task` en Flutter debe convertir objetos JSON y arrojar `FormatException` si los campos requeridos faltan o no son válidos.

### Código del Modelo: `lib/task.dart`
```dart
class Task {
  const Task({
    required this.id,
    required this.title,
    this.completed = false,
  });

  final String id;
  final String title;
  final bool completed;

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! String || title is! String || title.trim().isEmpty) {
      throw const FormatException('Invalid task data.');
    }
    return Task(
      id: id,
      title: title,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
```

### Pruebas Unitarias en Dart: `test/task_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/task.dart';

void main() {
  group('Task model unit tests (Section 4)', () {
    test('parses a valid task', () {
      final task = Task.fromJson({'id': 'task-1', 'title': 'Plan tests'});
      expect(task.id, 'task-1');
      expect(task.title, 'Plan tests');
    });

    test('rejects an empty title', () {
      expect(
        () => Task.fromJson({'id': 'task-1', 'title': ' '}),
        throwsFormatException,
      );
    });

    // Ejercicio práctico (Sección 4): Falta de ID
    test('rejects a missing ID', () {
      expect(
        () => Task.fromJson({'title': 'Plan tests'}),
        throwsFormatException,
      );
    });

    // Ejercicio práctico (Sección 4): Título válido en la longitud máxima de 120 caracteres
    test('accepts a valid title at the maximum allowed length of 120 characters', () {
      final maxTitle = 'a' * 120;
      final task = Task.fromJson({'id': 'task-max', 'title': maxTitle});
      expect(task.id, 'task-max');
      expect(task.title, maxTitle);
      expect(task.title.length, 120);
    });
  });
}
```

---

## Comandos de Ejecución

- **Para ejecutar las pruebas en Flutter:**
  ```bash
  flutter test test/task_test.dart
  ```
  *Resultado:* Todos los tests pasan en menos de 1 segundo.

- **Para ejecutar las pruebas del Backend:**
  ```bash
  cd backend
  npm test
  ```
  *Resultado:* PASS `test/validation.test.js`.
