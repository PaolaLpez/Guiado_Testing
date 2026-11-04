# 14. Automatización de Pruebas en CI y Comprensión de la Cobertura

## Objetivo
Ejecutar verificaciones automáticas y reproducibles ante cada confirmación (*push*) o solicitud de extracción (*pull request*), detectando fallos y regresiones de forma temprana antes de fusionar el código a la rama principal (`main`).

---

## Flujo de Trabajo en GitHub Actions (`.github/workflows/tests.yml`)

El pipeline divide las tareas en dos trabajos paralelos independientes:

```yaml
name: Tests

on:
  pull_request:
  push:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          cache-dependency-path: backend/package-lock.json
      - run: npm ci
      - run: npm test

  flutter:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: .
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter test
```

---

## Cobertura de Código vs. Calidad de las Pruebas

> **Lección Fundamental:**
> La cobertura de código (*code coverage*) mide qué líneas o ramas de código se ejecutaron durante la corrida de pruebas; **no demuestra que las pruebas hayan comprobado el comportamiento correcto ni las reglas de negocio críticas**.

Un proyecto con 100% de cobertura de código aún puede contener vulnerabilidades severas si:
- Ninguna prueba evalúa accesos cruzados entre usuarios distintos (BOLA).
- Ninguna prueba evalúa entradas nulas, vacías o inyecciones maliciosas.
- No se verifican los códigos de respuesta HTTP ni los mensajes de error mostrados al usuario.

---

## Ejercicio Práctico (Sección 14): Simulación de Fallo Intencional y Restauración en CI

> **Instrucción:** *Agregar una prueba al trabajo del backend, verificar que el pipeline de CI falle cuando el comportamiento esperado se rompe intencionalmente, y posteriormente restaurar el código.*

### Paso 1: Prueba de Aserción Agregada al Backend
Agregamos una prueba que valida que el endpoint `/api/v1/tasks` rechace tareas con títulos vacíos retornando código `400`:
```javascript
test('rejects an empty title with status 400', async () => {
  const token = await createTestUserAndGetToken();
  const response = await request(app)
    .post('/api/v1/tasks')
    .set('Authorization', `Bearer ${token}`)
    .send({ title: ' ' });
  expect(response.status).toBe(400);
});
```

### Paso 2: Romper Intencionalmente el Comportamiento
Modificamos temporalmente el controlador en `backend/src/app.js` para simular un bug donde se omite la validación y se permite guardar títulos vacíos:
```javascript
// BUG INTENCIONAL INTRODUCIDO:
// const validatedTitle = validateTitle(title);
const validatedTitle = title; // Permite cadenas con espacios en blanco sin validar
res.status(201).json({ id: 'task-bug', title: validatedTitle });
```

### Paso 3: Resultado de la Ejecución en CI (Fallo Detectado)
Al ejecutar `npm test` en el runner de CI:
```text
● task API security › rejects an empty title with status 400

  expect(received).toBe(expected) // Object.is equality

  Expected: 400
  Received: 201

    28 |       .set('Authorization', `Bearer ${token}`)
    29 |       .send({ title: ' ' });
  > 30 |     expect(response.status).toBe(400);
       |                             ^

Test Suites: 1 failed, 1 passed, 2 total
Tests:       1 failed, 12 passed, 13 total
Error: Process completed with exit code 1.
```
El pipeline de GitHub Actions se detiene inmediatamente con una cruz roja (`❌ Backend Tests Failed`), bloqueando la fusión del Pull Request.

### Paso 4: Restauración del Código
Restauramos la llamada a `validateTitle(title)` dentro de un bloque `try/catch` que responde con `400 Bad Request`.
Al volver a correr las pruebas:
```text
PASS test/task_api.test.js
PASS test/validation.test.js
Test Suites: 2 passed, 2 total
Tests:       13 passed, 13 total
```
El pipeline de CI pasa exitosamente a verde (`✅ All checks have passed`).
