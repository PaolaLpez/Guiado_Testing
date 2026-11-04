# 3. Exploración de la Aplicación mediante Carta de Prueba (Charter)

## Objetivo
Descubrir comportamientos inesperados, anomalías en la experiencia de usuario y fallos de resiliencia explorando el sistema guiado por una pregunta u objetivo específico (*Charter*), en lugar de seguir únicamente un guión predeterminado.

---

## Carta de Prueba (Test Charter)
> **Charter:** *"Explorar la creación y edición de tareas bajo condiciones de estrés, entradas extremas y variaciones de conectividad para identificar pérdidas de datos o estados inconsistentes de la UI."*
> 
> **Tiempo Asignado:** 15 - 20 minutos  
> **Tester:** QA Engineer (Entorno local aislado)  
> **Estrategia:** Probar una condición anómala a la vez y registrar eventos cronológicamente.

---

## Notas de la Sesión Exploratoria (Session Notes)

| Tiempo | Acción o Condición Evaluada | Observación / Comportamiento Detectado | Hallazgo o Seguimiento (Follow-up) |
| :---: | :--- | :--- | :--- |
| **00:00** | Inicio de sesión con usuario de prueba sintético A (`tester@example.test`). | La pantalla principal cargó inmediatamente mostrando el estado vacío `"No tasks yet."`. | Verificar contraste del texto del estado vacío y semántica para lectores de pantalla. |
| **03:00** | **Título Largo:** Intento de guardar una tarea con una cadena de 150 caracteres generados con caracteres acentuados y emojis (`"Tarea de prueba súper larga con acentos y emojis 🚀🎯..."`). | El diálogo bloqueó el guardado y mostró `"Title must be 120 characters or fewer."`. Sin embargo, el texto en el campo no tenía contador visible `150/120`. | **Sugerencia de Usabilidad:** Incorporar un `maxLength: 120` con contador nativo en el `TextField` de Flutter para evitar frustración. |
| **06:00** | **Título en Blanco:** Entrada de espacios en blanco puros (`"          "`). | El diálogo mostró correctamente el mensaje de error `"Enter a valid title."` sin realizar ninguna llamada de red innecesaria. | Validación del lado del cliente sincronizada con la validación de la función `validateTitle` del backend. |
| **09:00** | **Taps Rápidos Repetidos (Debouncing/Multi-touch):** Doble y triple toque muy veloz en el botón `"Save"` tras ingresar un título válido. | El diálogo se cerró, pero en una ocasión anterior sin debounce se crearon 2 tareas idénticas duplicadas en milisegundos. | **Riesgo:** Falta de bloqueo del botón durante la operación asíncrona de guardado. Se debe deshabilitar el botón durante el envío. |
| **12:00** | **Interrupción Breve de Red:** Desconectar la conexión a la API justo al presionar guardar la tarea. | La aplicación capturó el fallo y presentó la pantalla de error segura `"Could not load tasks."` junto con el botón de reintento (`Retry`). Al reconectar la red y pulsar "Retry", la lista se recuperó exitosamente. | Excelente recuperación de fallos mediante el componente `TaskListPanel`. |
| **15:00** | **Completar y desmarcar tarea rápidamente:** Alternar el estado de completado en rápida sucesión. | El tachado y el estado completado cambiaron fluidamente sin parpadeos ni excepciones en consola. | Validar que el servidor reciba la última versión del estado sin condiciones de carrera (*race conditions*). |

---

## ¿Qué resultó sorprendente durante la exploración? (Surprises & Key Takeaways)

1. **Robustez del widget ante fallos de red:**
   El botón de reintento (`Retry`) en el `TaskListPanel` permitió restaurar el estado del usuario sin obligarlo a reiniciar la aplicación ni a volver a escribir sus datos.
2. **Duplicación por toques rápidos:**
   En conexiones con latencia o dispositivos táctiles muy sensibles, la falta de inhabilitación inmediata del botón de confirmación (`onPressed: _isSaving ? null : _saveTask`) puede generar registros duplicados si el usuario presiona dos veces seguidas por impaciencia.
3. **Manejo uniforme de validación:**
   Tanto el frontend en Dart (`Task.fromJson` y validación de formulario) como el backend (`validateTitle.js`) aplican exactamente la misma regla de negocio: el título debe ser una cadena no vacía de 1 a 120 caracteres tras aplicar `.trim()`.
