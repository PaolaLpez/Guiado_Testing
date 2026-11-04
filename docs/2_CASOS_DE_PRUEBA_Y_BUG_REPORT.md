# 2. Casos de Prueba Útiles y Reportes de Errores (Bugs)

## Objetivo
Hacer que las pruebas sean repetibles y que los defectos sean sencillos de reproducir e investigar para el equipo de desarrollo, sin comprometer datos reales ni credenciales.

---

## Plantilla y Casos de Prueba (Test Cases)

### Caso de Prueba 1: TC-001 (Creación Exitosa de Tarea)
| Campo | Detalle |
| :--- | :--- |
| **ID y Título** | `TC-001`: Creación exitosa de tarea con título válido |
| **Precondiciones** | Usuario de prueba registrado (`tester@example.test`) con sesión iniciada en la app Flutter. Base de datos de pruebas accesible. |
| **Pasos** | 1. Tocar el botón flotante `+` (`Key('add-task-button')`).<br>2. Ingresar `'Plan tests'` en el campo `task-title-field`.<br>3. Tocar el botón `'Save'` (`Key('save-task-button')`). |
| **Datos de Prueba** | Título: `'Plan tests'` (longitud: 10 caracteres). |
| **Resultado Esperado** | El diálogo se cierra, se envía petición `POST /api/v1/tasks` con token válido, el servidor responde `201 Created` y la tarea `'Plan tests'` se visualiza en la lista con estado pendiente. |
| **Resultado Real** | Tarea creada y visible en la lista. |
| **Entorno** | Windows 11 / Android Emulator, Flutter 3.x, Node.js v22 Test Backend. |

### Caso de Prueba 2: TC-002 (Rechazo de Título en Blanco)
| Campo | Detalle |
| :--- | :--- |
| **ID y Título** | `TC-002`: Validación de rechazo ante título compuesto sólo por espacios |
| **Precondiciones** | Usuario con sesión activa en la aplicación. Diálogo de nueva tarea abierto. |
| **Pasos** | 1. Ingresar tres espacios en blanco `'   '` en `task-title-field`.<br>2. Presionar el botón `'Save'`. |
| **Datos de Prueba** | Título: `'   '` (espacios en blanco). |
| **Resultado Esperado** | La aplicación no envía petición vacía, resalta el campo en rojo y muestra el mensaje `'Enter a valid title.'`. |
| **Resultado Real** | Mensaje de validación visible; ninguna tarea vacía agregada a la lista. |
| **Entorno** | Flutter Test Framework / Chrome / Android. |

### Caso de Prueba 3: TC-003 (Aislamiento de Tareas entre Cuentas)
| Campo | Detalle |
| :--- | :--- |
| **ID y Título** | `TC-003`: Verificación de frontera de autorización entre usuarios distintos |
| **Precondiciones** | Usuario A (`owner@example.test`) tiene una tarea con ID `task-abc-123`. Usuario B (`stranger@example.test`) tiene un token válido emitido por el sistema. |
| **Pasos** | 1. Enviar una petición HTTP `GET /api/v1/tasks/task-abc-123`.<br>2. Encabezado: `Authorization: Bearer <Token_Usuario_B>`. |
| **Datos de Prueba** | ID de tarea de Usuario A: `task-abc-123`. Token: Usuario B. |
| **Resultado Esperado** | La API responde con código `404 Not Found` (o `403 Forbidden`) sin revelar título, contenido ni estado de la tarea del Usuario A. |
| **Resultado Real** | Código `404 Not Found` retornado. |
| **Entorno** | Supertest / Node.js test environment. |

---

## Ejercicio Práctico (Sección 2)

### Reporte de Error (Bug Report): Tarea desaparece tras marcarse como completada

| Campo | Información Detallada |
| :--- | :--- |
| **Bug ID** | `BUG-TASK-004` |
| **Resumen** | La tarea desaparece inmediatamente de la lista tras presionar el botón de marcar como completada en lugar de mostrarse tachada o con estado completado. |
| **Entorno** | - Dispositivo / OS: Windows 11 Pro / Android Emulator (API 34)<br>- Versión de la App: Flutter v1.0.0+1 (Build debug)<br>- Backend API: Node.js Express v1.0.0 (commit local) |
| **Precondiciones** | 1. Usuario con sesión iniciada con cuenta sintética `tester@example.test`.<br>2. Al menos una tarea activa creada (ej. `"Revisión de arquitectura"`). |
| **Pasos para Reproducir** | 1. Abrir la aplicación y verificar que la lista muestra la tarea `"Revisión de arquitectura"`.<br>2. Tocar el botón/icono de verificación (`complete-task-button`) al costado de la tarea.<br>3. Observar la pantalla de la lista de tareas. |
| **Resultado Esperado** | La tarea debe permanecer visible en la lista, actualizando su indicador visual (icono de checkbox marcado en verde, texto con tachado `lineThrough` y etiqueta `"Completed"`). Si existe un filtro de "Solo activas", este debe ser configurable por el usuario y no ejecutarse de forma silenciosa e irrevocable. |
| **Resultado Real** | La tarea se desvanece de inmediato de la vista y la lista queda en estado `"No tasks yet."` (vacía). En la consola no se visualiza ninguna notificación al usuario ni opción de deshacer (*undo*). |
| **Evidencia** | *Logs de la App:* `State updated: task removed from active list without filter UI toggled`.<br>*Captura:* Ver archivo `test_evidence/disappearing_task.png` (redactada, sin contraseñas). |
| **Severidad (Severity)** | **Media (Medium)**: El defecto no bloquea el uso de la aplicación ni causa crash de sistema, pero deteriora la experiencia del usuario y genera sensación de pérdida de datos accidental. |
| **Prioridad (Priority)** | **Alta (High)**: Afecta una funcionalidad central (marcar tareas terminadas) y causa confusión inmediata en el flujo primario de uso. Debe resolverse antes de la siguiente entrega/demostración. |

### Diferencia entre Severidad y Prioridad
- **Severidad (Impacto técnico):** Mide el impacto objetivo del defecto en la integridad del sistema (ej. crash con pérdida de datos = severidad crítica; error tipográfico = severidad baja).
- **Prioridad (Urgencia de negocio):** Mide cuándo debe corregirse el error en la planificación del sprint o lanzamiento (ej. un problema visual menor en la pantalla principal antes de una demo a inversionistas tiene prioridad alta a pesar de su baja severidad).
