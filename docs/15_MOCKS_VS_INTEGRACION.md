# 15. Elección Cuidadosa de Mocks y Gestión de Pruebas Inestables (Flaky Tests)

## Objetivo
Decidir cuándo aislar dependencias mediante dobles de prueba (*mocks*) y cuándo probar integraciones reales, evitando pruebas inestables (*flaky tests*) que fallen de forma intermitente.

---

## Ejercicio Práctico (Sección 15): Comparativa entre Prueba Simulada (Mock) y Prueba de Integración Real

> **Instrucción:** *Comparar una prueba de cliente de API con mock (`test/client_mock_test.dart`) frente a una prueba de integración de API con base de datos dedicada (`backend/test/task_api.test.js`). Registrar qué detecta y qué NO puede detectar cada una.*

### Tabla Comparativa de Capacidades:

| Dimensión de Análisis | Prueba con Cliente Mock (`client_mock_test.dart`) | Prueba de Integración Real (`task_api.test.js`) |
| :--- | :--- | :--- |
| **¿Qué DETECTA? (Fortalezas)** | 1. Errores de parsing y serialización en el cliente Dart (`Task.fromJson`).<br>2. Formato y presencia de la cabecera `Authorization: Bearer <token>`.<br>3. Manejo de códigos HTTP específicos (ej. 200 vs 401) en la lógica de UI.<br>4. Reacciones ante respuestas malformadas o campos nulos.<br>5. Ejecución ultra veloz (milisegundos) sin latencia ni red. | 1. Incompatibilidad real entre rutas Express y clientes.<br>2. Errores de persistencia, constraints de base de datos o tipos SQL.<br>3. Fallos reales en la verificación criptográfica del JWT.<br>4. Violaciones de autorización y aislamiento entre usuarios (BOLA).<br>5. Comportamiento de middlewares, headers CORS y payloads reales. |
| **¿Qué NO PUEDE DETECTAR? (Puntos Ciegos)** | 1. **Divergencia de contrato:** Si el backend cambia la clave `'title'` por `'name'`, el mock seguirá pasando si no se actualiza manualmente.<br>2. No detecta fallos en la conexión a la base de datos.<br>3. No valida si el backend realmente rechaza tokens vencidos.<br>4. No verifica reglas de negocio complejas del servidor. | 1. No detecta cómo reacciona la interfaz gráfica (UI) de Flutter ante el error.<br>2. No prueba la conversión del modelo en el dispositivo móvil.<br>3. Más lenta y susceptible a problemas de puertos ocupados o datos residuales si no se limpian adecuadamente. |

---

## Tabla Resumen de Tipos Comunes de Pruebas

| Tipo de Prueba | Propósito Principal | Quién la Ejecuta Habitualmente | Herramientas Típicas | Velocidad Relativa |
| :--- | :--- | :--- | :--- | :---: |
| **Unitaria (Unit)** | Verificar una función, método o clase pequeña en aislamiento | Desarrollador, QA Engineer | Jest, `flutter_test` | **Ultra Rápida** |
| **Widget / Componente** | Verificar el renderizado y los estados visuales de un componente | Desarrollador, QA Engineer | `flutter_test` | **Rápida** |
| **API / Integración** | Verificar rutas, middlewares, servicios y persistencia juntos | Desarrollador, QA Engineer | Supertest, cURL, PostgreSQL | **Media** |
| **End-to-End / UI** | Validar recorridos de usuario completos a través de toda la app | QA Engineer, Desarrollador | Flutter `integration_test` | **Lenta** |
| **Exploratoria** | Descubrir comportamientos inesperados mediante cartas guiadas | Tester, Desarrollador, PM | App real, notas, proxies | **Variable** |
| **Seguridad** | Validar autenticación, autorización (OWASP) y resiliencia | Tester especializado, QA | Supertest, OWASP ZAP | **Variable** |
| **Rendimiento / Carga** | Medir latencias, percentiles (p95) y concurrencia | Performance Tester, DevOps | k6, Locust | **Variable** |
| **Accesibilidad (a11y)** | Evaluar contrastes, lectores de pantalla y facilidad de uso | Tester, Especialista a11y | TalkBack, VoiceOver | **Variable** |
| **Compatibilidad** | Validar comportamiento en distintas pantallas y versiones OS | QA Engineer, Device Lab | Emuladores, BrowserStack | **Variable** |
| **Smoke / Regresión** | Confirmar salud básica tras build y prevenir regresiones | Desarrollador, CI Pipeline | CI/CD (GitHub Actions) | **Depende del alcance** |

---

## Plan de Práctica de Cuatro Semanas (Four-Week Practice Plan)

| Semana | Enfoque Principal | Entregable / Resultado Práctico |
| :---: | :--- | :--- |
| **Semana 1** | Mentalidad de tester, planes, casos de prueba y pruebas exploratorias | Un plan de pruebas formal, 3 casos de prueba detallados y 1 reporte de sesión exploratoria. |
| **Semana 2** | Pruebas unitarias, de widgets, de API y de integración | Suites de pruebas automatizadas para validación de títulos, estados de widgets y propiedad de tareas. |
| **Semana 3** | Recorridos E2E, valores límite, seguridad y accesibilidad | 1 flujo E2E completo automatizado, matriz de límites (título y contraseña), y notas de auditoría OWASP/a11y. |
| **Semana 4** | Rendimiento, compatibilidad, regresión y CI/CD | Script k6 ejecutado localmente, matriz de dispositivos, checklist de regresión y pipeline funcional en GitHub Actions. |
