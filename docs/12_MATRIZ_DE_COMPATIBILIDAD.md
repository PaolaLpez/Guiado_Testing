# 12. Pruebas de Compatibilidad de Dispositivos y Plataformas

## Objetivo
Identificar problemas de diseño, desbordamiento (*overflow*), ciclos de vida o discrepancias de red que solo aparecen en modelos de pantalla específicos o versiones particulares del sistema operativo.

---

## Matriz de Compatibilidad de Plataformas

| Plataforma | Perfil de Dispositivo | Rango de SO | Verificaciones Clave Realizadas |
| :--- | :--- | :--- | :--- |
| **Android** | Pantalla Pequeña (ej. 4.7", 720x1280) | Mínimo soportado (Android 8.0 / API 26) | Flujo de login, escalado de fuentes, ausencia de RenderFlex overflows, teclado virtual. |
| **Android** | Dispositivo Estándar / Mainstream (6.4", 1080x2400) | Android 14 / 15 actual | CRUD completo de tareas, refresco de sesión, animación de checkboxes, rendimiento a 60/120fps. |
| **iOS** | Pantalla Pequeña (iPhone SE 3ra Gen) | Mínimo soportado (iOS 15.0) | Layout compacto, almacenamiento en Keychain/SecureStorage, accesibilidad. |
| **iOS** | Dispositivo Estándar (iPhone 15 / 16 Pro) | iOS 17 / 18 actual | Manejo de Dynamic Island / Notch con `SafeArea`, recuperación de conectividad en segundo plano. |
| **Emulador / Desktop** | Perfil de Desarrollo (Windows / macOS / Linux) | Toolchain actual | Pruebas automatizadas rápidas de humo (smoke tests) y regresión continua. |

---

## Ejercicio Práctico (Sección 12): Prueba en Pantalla Pequeña vs. Pantalla Grande

> **Instrucción:** *Probar la lista de tareas en una pantalla pequeña y en una pantalla grande. Registrar desbordamientos (overflows), textos cortados y controles difíciles de presionar.*

### 1. Pruebas en Pantalla Pequeña (Resolución: 320 x 568 dp - Perfil Compacto):
- **Desbordamientos detectados:** 
  Al desplegar el teclado en el diálogo de creación de tareas en resoluciones verticales bajas (<600dp), el diálogo tapaba los botones de acción si no se utilizaba scroll.
  - *Solución implementada:* Envolver el contenido en `SingleChildScrollView` y definir `mainAxisSize: MainAxisSize.min`.
- **Textos cortados:**
  Títulos de tareas que alcanzaban los 120 caracteres generaban dos líneas. En `ListTile`, si no se configura `maxLines` o ajuste elástico, el subtítulo se sobreponía.
  - *Solución implementada:* Permitir ajuste multilinea nativo en el `ListTile(title: Text(task.title))`.
- **Controles táctiles:**
  El botón de eliminar o completar debe conservar un `minTargetSize` de al menos 48x48dp mediante `IconButton(iconSize: 24, padding: EdgeInsets.all(12))`.

### 2. Pruebas en Pantalla Grande (Tablet / Desktop / Web - 1920 x 1080 dp):
- **Uso del espacio:**
  En pantallas anchas, un `ListView` que se expande al 100% del ancho de la pantalla hace que el título quede en el extremo izquierdo y el botón de acción en el extremo derecho lejano, dificultando la correlación visual.
  - *Solución implementada:* Utilizar un contenedor centrado con restricción máxima de ancho:
    ```dart
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: taskListView,
    )
    ```
- **Foco de teclado:**
  En desktop, el usuario espera poder presionar la tecla `Enter` para enviar el formulario y `Escape` para cerrar el diálogo.
