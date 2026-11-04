# 13. Pruebas de Humo (Smoke), Regresión y Gestión de Datos de Prueba

## Objetivo
Verificar con rapidez el estado de salud crítico del sistema tras cada nueva compilación (*Smoke Test*) y asegurar que las funcionalidades preexistentes sigan funcionando correctamente tras introducir cambios en el código (*Regression Test*).

---

## Suite de Humo (Smoke Suite - 5 Pasos Esenciales)

La suite de humo debe ejecutarse en menos de 3 minutos tras cada despliegue o build:
1. **Apertura de la aplicación:** La aplicación abre sin crashear y muestra la pantalla inicial de inicio de sesión.
2. **Inicio de sesión exitoso:** El usuario sintético ingresa credenciales válidas y recibe su token de acceso JWT.
3. **Carga de la lista de tareas:** La pantalla principal consulta `/api/v1/tasks` y despliega la lista sin errores visuales.
4. **Creación de tarea básica:** Se crea una tarea simple (`"Smoke test task"`) y se valida que aparezca en pantalla.
5. **Cierre de sesión:** El usuario cierra su sesión de forma limpia y el token se revoca o elimina del almacenamiento seguro.

---

## Ejercicio Práctico (Sección 13): Lista de Verificación de Regresión (*Regression Checklist*)

> **Instrucción:** *Crear una lista de verificación de regresión exhaustiva para la creación, edición, completado, eliminación y control de acceso cruzado entre usuarios.*

| ID de Regresión | Área / Funcionalidad | Pasos de Verificación | Resultado Esperado | Prioridad | Automatizado |
| :---: | :--- | :--- | :--- | :---: | :---: |
| **REG-001** | **Creación de Tarea** | 1. Tocar botón `+`.<br>2. Ingresar título válido.<br>3. Presionar guardar. | La tarea se persiste con `ownerId` del usuario actual y aparece en la lista. | **Crítica (P0)** | Sí (`flutter_test` & `Jest`) |
| **REG-002** | **Validación de Título** | 1. Ingresar título en blanco.<br>2. Ingresar título >120 caracteres. | Se muestra mensaje de error. Ninguna tarea corrupta se envía al servidor. | **Alta (P1)** | Sí (`flutter_test` & `Jest`) |
| **REG-003** | **Edición de Tarea** | 1. Seleccionar tarea existente.<br>2. Modificar su texto.<br>3. Confirmar cambios. | El título se actualiza en backend (`PUT /tasks/:id`) y se refleja en la vista. | **Alta (P1)** | Sí (`Supertest`) |
| **REG-004** | **Completado de Tarea** | 1. Tocar botón de verificación de tarea.<br>2. Recargar vista. | La tarea muestra estado completado (tachado y subtítulo `"Completed"`). | **Alta (P1)** | Sí (`test/app_journey_test.dart`) |
| **REG-005** | **Eliminación de Tarea** | 1. Enviar petición `DELETE /api/v1/tasks/:id`.<br>2. Consultar lista. | El servidor retorna `204 No Content` y la tarea ya no figura en la lista. | **Alta (P1)** | Sí (`Supertest`) |
| **REG-006** | **Acceso Cruzado: Lectura (BOLA)** | Usuario B consulta con su token el ID de una tarea perteneciente al Usuario A. | El servidor responde `404 Not Found` (o `403`). No se filtran datos del Usuario A. | **Crítica (P0)** | Sí (`backend/test/task_api.test.js`) |
| **REG-007** | **Acceso Cruzado: Edición (BOLA)** | Usuario B envía `PUT /tasks/:id_A` con un nuevo título. | El servidor deniega la operación con `403 Forbidden` / `404`. El título no cambia. | **Crítica (P0)** | Sí (`backend/test/task_api.test.js`) |
| **REG-008** | **Inyección de Propiedad (BOPLA)** | Usuario A intenta actualizar su propia tarea enviando `ownerId: "user-B"`. | El servidor ignora el campo inyectado y preserva la titularidad del Usuario A. | **Crítica (P0)** | Sí (`backend/test/task_api.test.js`) |
| **REG-009** | **Expiración y Refresco de Token** | Simular token expirado y realizar petición con refresh token. | La API rota el token sin forzar reautenticación manual del usuario. | **Media (P2)** | Sí (`Node.js backend`) |
| **REG-010** | **Recuperación tras Fallo de Red** | Desconectar red durante carga de lista y presionar "Retry". | El panel de error presenta el botón y reintenta la petición exitosamente. | **Media (P2)** | Sí (`test/task_list_panel_test.dart`) |

---

## Gestión de Datos de Prueba (Test Data Management)
- **Principio de Aislamiento:** Cada suite de pruebas crea sus propios usuarios y tareas con prefijos únicos (`uuid` / `Date.now()`).
- **Limpieza Concurrente:** La base de datos de pruebas se reinicia antes y después de cada ciclo (`resetDb()`).
- **Prohibido usar producción:** Las pruebas automatizadas nunca se ejecutan contra bases de datos compartidas ni con datos reales de clientes.
