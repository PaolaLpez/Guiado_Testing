# 11. Pruebas de Usabilidad y Accesibilidad (a11y)

## Objetivo
Confirmar que diferentes usuarios, incluyendo personas con discapacidades visuales o motrices, puedan entender, navegar y operar la aplicación sin barreras.

---

## Lista de Verificación Rápida de Accesibilidad

- [x] **Contraste de texto y controles:** Contraste mínimo de 4.5:1 para texto estándar y 3:1 para texto grande/elementos gráficos de UI (WCAG 2.1 AA).
- [x] **Nombres accesibles y etiquetas claras:** Botones y campos de texto poseen etiquetas legibles y nombres semánticos (`labelText`, `tooltip`).
- [x] **Compatibilidad con lectores de pantalla (TalkBack / VoiceOver):** Los lectores de pantalla anuncian títulos de tareas, estados (pendiente/completada) y errores en un orden lógico.
- [x] **Escalado de fuentes (Text Scaling):** La interfaz no se desborda cuando el usuario configura un factor de escala de fuente de hasta 2.0x (200%).
- [x] **Áreas táctiles (*Touch Targets*):** Todos los botones interactivos e iconos tienen un tamaño táctil mínimo de 48x48 píxeles lógicos.
- [x] **Mensajes de error orientados a la recuperación:** Los mensajes indican claramente qué falló y cómo corregirlo (ej. *"Title must be 120 characters or fewer"*).
- [x] **Múltiples canales sensoriales para el estado:** El estado de completado no se comunica únicamente con color verde, sino también con un icono diferente (checkbox marcado) y texto explícito (`Completed`).
- [x] **Navegación por teclado y switch:** Orden de foco coherente mediante tabulación y teclado físico.

---

## Ejercicio Práctico (Sección 11): Auditoría con Lector de Pantalla y Texto Aumentado

> **Instrucción:** *Habilitar un lector de pantalla y un tamaño de texto grande. Crear una tarea, provocar un error de validación y registrar cualquier control sin etiquetar o texto recortado.*

### Procedimiento del Experimento:
1. Configuración de accesibilidad activada en dispositivo de prueba / emulador:
   - **Tamaño de fuente:** Máximo (factor de escala 1.5x - 2.0x).
   - **Lector de pantalla:** TalkBack (Android) o herramienta de inspección semántica de Flutter (`showSemanticsDebugger: true`).
2. Flujo ejecutado:
   - Navegación al diálogo "New Task".
   - Intento de guardar con campo vacío para detonar el error.
   - Creación de una tarea válida y posterior marcado de completado.

### Registro de Hallazgos y Correcciones Realizadas:

| Elemento / Control | Comportamiento Inicial (Riesgo Detectado) | Corrección Implementada en el Código Flutter | Estado Final |
| :--- | :--- | :--- | :---: |
| **Botón de marcar tarea como completada** | El icono `IconButton` carecía de `tooltip`, anunciándose genéricamente como *"Botón"* sin contexto en TalkBack. | Se agregó `tooltip: 'Mark Complete'` y soporte de `Semantics` en el widget `ListTile`. | **Corregido** ✅ |
| **Botón de cerrar sesión en la AppBar** | Se anunciaba sólo como icono gráfico. | Se agregó `tooltip: 'Sign Out'` y etiqueta semántica en la `AppBar`. | **Corregido** ✅ |
| **Desbordamiento de texto en pantallas pequeñas con fuente 2.0x** | Al aumentar la fuente al 200%, el diálogo de creación provocaba un error de RenderFlex overflow (`A RenderFlex overflowed by 18 pixels on the bottom`). | Se envolvió el cuerpo del formulario en un `SingleChildScrollView` con restricciones elásticas. | **Corregido** ✅ |
| **Anuncio del error de validación** | El mensaje de error de validación era visible visualmente pero no se focalizaba automáticamente en el lector. | El `TextField` utiliza ahora `errorText` nativo del `InputDecoration`, el cual anuncia de inmediato el error al lector de pantalla. | **Corregido** ✅ |

---

## Verificación de Semántica en Pruebas Automatizadas de Flutter
Es posible asegurar la accesibilidad mediante pruebas automatizadas con el tester de Flutter:
```dart
testWidgets('has accessible touch targets and semantics', (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(const TaskManagerApp());
  
  // Verifica que el botón de login tenga etiqueta accesible
  expect(tester.getSemantics(find.byKey(const Key('login-button'))), 
         matchesSemantics(label: 'Sign In', isButton: true));
         
  handle.dispose();
});
```
