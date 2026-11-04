# 8. Partición de Equivalencia y Análisis de Valores Límite

## Objetivo
Seleccionar datos de prueba eficientes y representativos que cubran grupos de entrada significativos y casos en los extremos, evitando pruebas redundantes.

---

## 1. Campo de Título de la Tarea (1 a 120 Caracteres)

| Partición o Límite | Entrada de Ejemplo | Resultado Esperado | Justificación de la Partición |
| :--- | :--- | :--- | :--- |
| **Vacío** | `""` | Rechazar (400 / Validación UI) | Valor nulo o sin contenido. |
| **Solo espacios en blanco** | `"   "` | Rechazar (400) | Se reduce a longitud 0 tras `.trim()`. |
| **Longitud mínima válida** | `"a"` (1 carácter) | Aceptar (201) | Límite inferior exacto. |
| **Título típico válido** | `"Plan tests"` (10 car.) | Aceptar (201) | Partición de equivalencia válida estándar. |
| **Longitud máxima válida** | Cadena de 120 caracteres | Aceptar (201) | Límite superior exacto. |
| **Justo por encima del límite** | Cadena de 121 caracteres | Rechazar (400) | Límite inmediatamente fuera del rango. |
| **Tipo incorrecto en JSON** | `title: 42` o `title: null` | Rechazar de forma segura | Robustez de tipos en el deserializador. |

---

## 2. Ejercicio Práctico (Sección 8): Campo de Contraseña (Password)

> **Regla de Negocio:**
> La contraseña debe contener entre **8 y 64 caracteres**. No debe almacenar contraseñas reales durante las pruebas.

### Tabla de Partición de Equivalencia y Valores Límite para Contraseña:

| Partición / Límite | Entrada de Prueba Sintética | Longitud | Resultado Esperado | Justificación Técnica |
| :--- | :--- | :---: | :---: | :--- |
| **Vacía** | `""` | 0 | **Rechazar** | No se permite contraseña nula o vacía. Mensaje: *"Please enter a password."* |
| **Justo debajo del mínimo** | `"Aa1!567"` | 7 | **Rechazar** | Límite inferior - 1. Violación de longitud mínima de seguridad. |
| **Longitud mínima válida** | `"Aa1!5678"` | 8 | **Aceptar** | Límite inferior exacto (Boundary Value Mínimo). |
| **Valor típico válido** | `"SecurePass#2026"` | 15 | **Aceptar** | Partición válida estándar de uso diario. |
| **Longitud máxima válida** | `"K9#mQ2$z..."` (64 caracteres) | 64 | **Aceptar** | Límite superior exacto (Boundary Value Máximo). |
| **Justo sobre el máximo** | Cadena de 65 caracteres | 65 | **Rechazar** | Límite superior + 1. Prevención de ataques DoS en algoritmos de hash como bcrypt/argon2. |
| **Exceso desmedido / Payload** | Cadena de 10,000 caracteres | 10000 | **Rechazar** | Protección de buffers y prevención de saturación de CPU en cómputo criptográfico. |
| **Tipo de dato no cadena** | `password: 12345678` | N/A | **Rechazar** | La API o el parser de Dart debe validar `typeof === 'string'`. |

---

## Buenas Prácticas de Seguridad en Pruebas de Credenciales
1. **Credenciales sintéticas:** Jamás usar contraseñas personales o corporativas reales en scripts de prueba ni en archivos `.test.js` / `.dart`.
2. **Redacción de logs:** Asegurar que los logs del servidor y del cliente no impriman el valor del campo `password` en texto plano durante fallos de aserción.
