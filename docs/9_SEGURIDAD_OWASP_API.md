# 9. Pruebas de Comportamiento Negativo y Seguridad Básica (OWASP API Top 10)

## Objetivo
Verificar que la aplicación rechace de manera segura peticiones maliciosas, no autorizadas o con formatos corruptos, garantizando la confidencialidad e integridad de los datos de cada usuario.

---

## Lista de Verificación OWASP API Security (Task Manager)

| Preocupación de Seguridad OWASP | Medida Implementada en Task Manager |
| :--- | :--- |
| **API1: Broken Object-Level Authorization (BOLA)** | Cada consulta (`GET /tasks/:id`, `PUT /tasks/:id`, `DELETE /tasks/:id`) está estrictamente acotada al `ownerId` extraído del token JWT verificado en el servidor. |
| **API2: Broken Authentication** | Tokens manipulados, vencidos, vacíos o sin firma válida son rechazados inmediatamente con código `401 Unauthorized`. |
| **API3: Broken Object Property-Level Authorization (BOPLA / Mass Assignment)** | Los clientes solo pueden modificar `title` o `completed`. Si el cliente envía `ownerId`, el servidor lo ignora o rechaza, manteniendo la propiedad derivada del token del servidor. |
| **API4: Unrestricted Resource Consumption** | Límites de tamaño de payload en `express.json({ limit: '10kb' })`, títulos acotados a 120 caracteres y paginación en listas. |
| **API5: Broken Function-Level Authorization** | Rutas administrativas o protegidas exigen roles y tokens válidos. |
| **API6: Unrestricted Access to Sensitive Business Flows** | Los endpoints de inicio de sesión (`/login`) y refresco (`/refresh`) cuentan con límites de tasa (*rate limiting*). |
| **API7: Server-Side Request Forgery (SSRF)** | La aplicación no acepta URLs externas provistas por el usuario para ser consumidas por el servidor. |
| **API8: Security Misconfiguration** | Uso de cabeceras seguras (Helmet), políticas CORS restringidas a dominios conocidos y rechazo de HTTP inseguro en producción. |
| **API9: Improper Inventory Management** | Rutas versionadas (`/api/v1/...`) con documentación activa y eliminación de endpoints deprecados. |
| **API10: Unsafe Consumption of APIs** | Validación y tipado estricto de todas las respuestas de APIs externas antes de procesarlas. |

---

## Ejercicio Práctico (Sección 9): Prueba de Asignación Masiva (*Mass Assignment*)

> **Instrucción:** *En el entorno de pruebas, intentar actualizar una tarea enviando un campo `ownerId`. Verificar que la API ignore o rechace este campo y mantenga la propiedad derivada del servidor.*

### Prueba Automatizada en Jest / Supertest (`backend/test/task_api.test.js`):
```javascript
test('retains server-derived ownership and ignores or rejects client-supplied ownerId on update', async () => {
  // 1. Crear usuario víctima legítimo y su tarea
  const ownerToken = await createTestUserAndGetToken('victim@example.test');
  const originalOwnerId = jwt.decode(ownerToken).id;
  const taskId = await createTask(ownerToken, 'Legitimate task');

  // 2. Intentar inyectar un ownerId ajeno en el cuerpo del PUT
  const response = await request(app)
    .put(`/api/v1/tasks/${taskId}`)
    .set('Authorization', `Bearer ${ownerToken}`)
    .send({
      title: 'Updated title safely',
      ownerId: 'malicious-injected-owner-id', // Intento de transferencia indebida
    });

  // La petición actualiza el título pero NO la propiedad
  expect(response.status).toBe(200);

  // 3. Verificar en la base de datos que la tarea sigue perteneciendo al usuario original
  const storedTask = db.tasks.find((t) => t.id === taskId);
  expect(storedTask.ownerId).toBe(originalOwnerId);
  expect(storedTask.ownerId).not.toBe('malicious-injected-owner-id');
});
```

### Conclusión Técnica
Esta prueba previene la vulnerabilidad de **Asignación Masiva (Mass Assignment / BOPLA)**: el servidor nunca debe permitir que el cliente establezca campos de control de acceso ni identificadores de propietario mediante parámetros del cuerpo de la solicitud (`req.body`). La identidad debe ser derivada exclusivamente de la sesión criptográficamente validada (`req.user.id`).
