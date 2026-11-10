# Guía Práctica de Testing de Aplicaciones: Task Manager (Flutter + Node.js)

Este repositorio contiene la implementación completa y ejecutable del proyecto de aprendizaje y actividad **"Become a Better Application Tester: A Hands-On Task Manager Guide"**.

El proyecto abarca pruebas en múltiples niveles de la pirámide de testing:
- **Frontend Móvil:** Aplicación completa en **Flutter** con autenticación, creación de tareas, marcado de completado, manejo de estados (cargando, vacío, error, datos) y cierre de sesión.
- **Pruebas de Flutter:** Pruebas unitarias de modelos, pruebas de widgets de UI con callbacks y pruebas de recorridos de usuario End-to-End (`flutter_test` e `integration_test`).
- **Backend API:** Servidor REST en **Node.js/Express** con autenticación JWT, endpoints de tareas con estricto control de acceso y propiedad (OWASP BOLA/BOPLA), y endpoint `/health`.
- **Pruebas de Backend:** Pruebas unitarias con **Jest** y pruebas de integración/seguridad de API con **Supertest**.
- **Pruebas de Rendimiento:** Script de carga con **k6**.
- **CI/CD:** Pipeline automatizado en **GitHub Actions** (`.github/workflows/tests.yml`).
- **Documentación y Reportes:** 15 documentos detallados que resuelven cada uno de los ejercicios prácticos del documento original.

---

## Estructura del Proyecto

```text
Guiado_Testing/
├── .github/
│   └── workflows/
│       └── tests.yml                 # Pipeline CI en GitHub Actions (Sección 14)
├── backend/                          # Backend Node.js / Express REST API
│   ├── src/
│   │   ├── app.js                    # API Express con JWT, tareas y scoping de propiedad
│   │   └── tasks/
│   │       └── validation.js         # Validador de títulos (1 a 120 caracteres)
│   ├── test/
│   │   ├── task_api.test.js          # Pruebas de API e integración con Supertest (Sección 6 y 9)
│   │   └── validation.test.js        # Pruebas unitarias en Jest (Sección 4)
│   ├── package.json                  # Dependencias y scripts de prueba del backend
│   └── server.js                     # Servidor ejecutable para pruebas locales y k6
├── docs/                             # Documentación y resolución de los 15 ejercicios prácticos
│   ├── 1_PLAN_Y_CRITERIOS_ACEPTACION.md
│   ├── 2_CASOS_DE_PRUEBA_Y_BUG_REPORT.md
│   ├── 3_PRUEBAS_EXPLORATORIAS.md
│   ├── 4_PRUEBAS_UNITARIAS.md
│   ├── 5_PRUEBAS_DE_WIDGETS.md
│   ├── 6_PRUEBAS_API_INTEGRACION.md
│   ├── 7_RECORRIDOS_DE_USUARIO_E2E.md
│   ├── 8_PARTICION_EQUIVALENCIA_Y_LIMITES.md
│   ├── 9_SEGURIDAD_OWASP_API.md
│   ├── 10_RENDIMIENTO_Y_CARGA_K6.md
│   ├── 11_USABILIDAD_Y_ACCESIBILIDAD.md
│   ├── 12_MATRIZ_DE_COMPATIBILIDAD.md
│   ├── 13_SMOKE_Y_REGRESION.md
│   ├── 14_CI_CD_GITHUB_ACTIONS.md
│   └── 15_MOCKS_VS_INTEGRACION.md
├── integration_test/
│   └── app_test.dart                 # Prueba de integración Flutter E2E (Sección 7)
├── lib/
│   ├── main.dart                     # App Flutter con Login, My Tasks, FAB y Logout
│   ├── task.dart                     # Modelo Task con serialización/deserialización JSON
│   ├── task_api_client.dart          # Cliente API HTTP desacoplado para pruebas con mocks
│   └── task_list_panel.dart          # Widget con estados Loading, Empty, Error y Retry
├── performance/
│   └── health-test.js                # Script de pruebas de carga en k6 (Sección 10)
├── test/
│   ├── app_journey_test.dart         # Recorrido E2E con marcado de completado y logout (Sección 7)
│   ├── client_mock_test.dart         # Prueba de cliente con mock HTTP (Sección 15)
│   ├── task_list_panel_test.dart     # Pruebas de widgets y callback del botón Retry (Sección 5)
│   └── task_test.dart                # Pruebas unitarias del modelo Task y límites (Sección 4)
├── pubspec.yaml                      # Configuración de dependencias de Flutter
└── README.md                         # Este documento
```

---

## Cómo Ejecutar las Pruebas

### 1. Pruebas de Flutter (Unitarias, Widgets y Recorridos E2E)
Asegúrate de estar en la raíz del proyecto (`Guiado_Testing`):
```bash
flutter test
```
*Todas las suites de prueba (`task_test.dart`, `task_list_panel_test.dart`, `app_journey_test.dart` y `client_mock_test.dart`) se ejecutan y aprueban automáticamente.*

Para ejecutar una prueba específica:
```bash
# Pruebas unitarias del modelo Task
flutter test test/task_test.dart

# Pruebas de widget del TaskListPanel
flutter test test/task_list_panel_test.dart

# Recorrido de usuario E2E completo
flutter test test/app_journey_test.dart
```

### 2. Pruebas del Backend (Jest y Supertest)
Navega a la carpeta `backend`:
```bash
cd backend
npm test
```
*Se ejecutan `validation.test.js` y `task_api.test.js`, validando la lógica de negocio, autenticación JWT, fronteras de autorización y rechazo de manipulación de `ownerId`.*

### 3. Pruebas de Rendimiento con k6
1. Inicia la API del backend:
   ```bash
   cd backend
   npm start
   ```
2. En otra terminal, ejecuta el script de k6:
   ```bash
   k6 run --env BASE_URL=http://localhost:3000 performance/health-test.js
   ```

---

## Resumen de Ejercicios Prácticos Resueltos

| Sección | Tema | Ejercicio Solicitado en la Guía | Dónde se Encuentra |
| :---: | :--- | :--- | :--- |
| **1** | Mentalidad de Tester | 3 criterios de aceptación (éxito, entrada inválida, frontera de permisos). | [`docs/1_PLAN_Y_CRITERIOS_ACEPTACION.md`](docs/1_PLAN_Y_CRITERIOS_ACEPTACION.md) |
| **2** | Casos de Prueba y Bugs | Reporte de defecto para una tarea que desaparece tras marcarse como completada. | [`docs/2_CASOS_DE_PRUEBA_Y_BUG_REPORT.md`](docs/2_CASOS_DE_PRUEBA_Y_BUG_REPORT.md) |
| **3** | Pruebas Exploratorias | Sesión de 15 min probando título largo, en blanco, taps repetidos y caída de red. | [`docs/3_PRUEBAS_EXPLORATORIAS.md`](docs/3_PRUEBAS_EXPLORATORIAS.md) |
| **4** | Pruebas Unitarias | Tests para ID faltante y título válido en la longitud máxima (120 car.). | [`test/task_test.dart`](test/task_test.dart) & [`docs/4_PRUEBAS_UNITARIAS.md`](docs/4_PRUEBAS_UNITARIAS.md) |
| **5** | Pruebas de Widgets | Botón de reintento (`Retry`) en estado de error y test de invocación exacta (1 vez). | [`lib/task_list_panel.dart`](lib/task_list_panel.dart) & [`test/task_list_panel_test.dart`](test/task_list_panel_test.dart) |
| **6** | Pruebas de API | Tests para ID inválido, título faltante e intento de actualización cruzada. | [`backend/test/task_api.test.js`](backend/test/task_api.test.js) & [`docs/6_PRUEBAS_API_INTEGRACION.md`](docs/6_PRUEBAS_API_INTEGRACION.md) |
| **7** | Recorridos de Usuario | Extender el flujo: marcar tarea completada, cerrar sesión y validar Login. | [`test/app_journey_test.dart`](test/app_journey_test.dart) & [`integration_test/app_test.dart`](integration_test/app_test.dart) |
| **8** | Valores Límite | Tabla de equivalencia y valores límite aplicada al campo de contraseña. | [`docs/8_PARTICION_EQUIVALENCIA_Y_LIMITES.md`](docs/8_PARTICION_EQUIVALENCIA_Y_LIMITES.md) |
| **9** | Seguridad OWASP | Intento de inyectar `ownerId` en actualización de tarea y verificación de rechazo. | [`backend/test/task_api.test.js`](backend/test/task_api.test.js) & [`docs/9_SEGURIDAD_OWASP_API.md`](docs/9_SEGURIDAD_OWASP_API.md) |
| **10** | Rendimiento (k6) | Modificación de umbrales (*thresholds*) y explicación del reporte generado. | [`performance/health-test.js`](performance/health-test.js) & [`docs/10_RENDIMIENTO_Y_CARGA_K6.md`](docs/10_RENDIMIENTO_Y_CARGA_K6.md) |
| **11** | Accesibilidad | Auditoría con lector de pantalla (TalkBack) y texto aumentado al 200%. | [`docs/11_USABILIDAD_Y_ACCESIBILIDAD.md`](docs/11_USABILIDAD_Y_ACCESIBILIDAD.md) |
| **12** | Compatibilidad | Pruebas en pantalla pequeña vs grande, overflows y tamaños táctiles. | [`docs/12_MATRIZ_DE_COMPATIBILIDAD.md`](docs/12_MATRIZ_DE_COMPATIBILIDAD.md) |
| **13** | Regresión y Humo | Checklist de regresión para creación, edición, completado, borrado y permisos. | [`docs/13_SMOKE_Y_REGRESION.md`](docs/13_SMOKE_Y_REGRESION.md) |
| **14** | CI y Cobertura | Simulación de fallo intencional en CI y proceso de restauración. | [`.github/workflows/tests.yml`](.github/workflows/tests.yml) & [`docs/14_CI_CD_GITHUB_ACTIONS.md`](docs/14_CI_CD_GITHUB_ACTIONS.md) |
| **15** | Mocks vs Integración | Comparativa exhaustiva: qué detecta y qué omite un mock vs una prueba con BD real. | [`test/client_mock_test.dart`](test/client_mock_test.dart) & [`docs/15_MOCKS_VS_INTEGRACION.md`](docs/15_MOCKS_VS_INTEGRACION.md) |

---

## Lista de Habilidades de Tester Demostradas (Tester Skills Checklist)

- [x] Convertir requerimientos en criterios de aceptación observables.
- [x] Redactar casos de prueba reproducibles y reportes de errores claros.
- [x] Explorar con una carta enfocada (*charter*) y registrar notas de sesión.
- [x] Seleccionar entradas límite representativas y casos negativos.
- [x] Comprender y probar la autenticación frente a la autorización (BOLA/BOPLA).
- [x] Probar respuestas de API y estados de la UI de forma independiente.
- [x] Proteger credenciales y datos personales en la evidencia de prueba.
- [x] Comunicar el riesgo y la incertidumbre con precisión técnica.
- [x] Usar automatización en CI donde ahorra esfuerzo repetitivo.
- [x] Realizar pruebas de rendimiento y seguridad de forma ética y autorizada.

<img width="773" height="472" alt="image" src="https://github.com/user-attachments/assets/74b5446a-5cdf-45e5-9d1a-fbbaa45fac94" />
<img width="768" height="476" alt="image" src="https://github.com/user-attachments/assets/9bb8db21-b3ee-4b1c-8563-7d10773aea6e" />
<img width="767" height="474" alt="image" src="https://github.com/user-attachments/assets/80882cc9-9831-425f-8ef4-66b8d8496637" />
<img width="953" height="501" alt="image" src="https://github.com/user-attachments/assets/ead626d9-b967-46c4-ab3e-07bd55065ba4" />
<img width="953" height="498" alt="image" src="https://github.com/user-attachments/assets/f0d5d867-aed0-4354-9d53-ee879ce9b62b" />




