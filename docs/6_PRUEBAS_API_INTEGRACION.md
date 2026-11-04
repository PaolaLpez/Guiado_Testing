# 6. Pruebas de API e Integración en el Backend

## Objetivo
Comprobar que las rutas, middlewares de autenticación, controladores, servicios y la lógica de base de datos funcionen juntos armónicamente, protegiendo las fronteras de autorización e impidiendo accesos cruzados entre usuarios.

---

## Pruebas con Supertest (`backend/test/task_api.test.js`)

Se utiliza `Supertest` sobre la aplicación Express aislada (`backend/src/app.js`), recreando y limpiando los datos antes de cada prueba (`resetDb()`).

### Casos de Prueba Implementados:

1. **Rechazo de creación sin autenticación (401):**
   ```javascript
   test('rejects task creation without authentication', async () => {
     const response = await request(app)
       .post('/api/v1/tasks')
       .send({ title: 'Plan tests' });
     expect(response.status).toBe(401);
   });
   ```

2. **Rechazo de título en blanco (400):**
   ```javascript
   test('rejects an empty title', async () => {
     const token = await createTestUserAndGetToken();
     const response = await request(app)
       .post('/api/v1/tasks')
       .set('Authorization', `Bearer ${token}`)
       .send({ title: ' ' });
     expect(response.status).toBe(400);
   });
   ```

3. **Aislamiento de lectura entre usuarios (403 / 404):**
   ```javascript
   test('does not let one user read another user task', async () => {
     const owner = await createTestUserAndGetToken();
     const stranger = await createTestUserAndGetToken();
     const taskId = await createTask(owner, 'Private task');

     const response = await request(app)
       .get(`/api/v1/tasks/${taskId}`)
       .set('Authorization', `Bearer ${stranger}`);
     expect([403, 404]).toContain(response.status);
   });
   ```

---

## Ejercicios Prácticos (Sección 6)

### 1. ID de tarea no válido o inexistente:
```javascript
test('rejects an invalid / non-existent task ID with 404', async () => {
  const token = await createTestUserAndGetToken();
  const response = await request(app)
    .get('/api/v1/tasks/non-existent-task-id-999')
    .set('Authorization', `Bearer ${token}`);
  expect(response.status).toBe(404);
});
```

### 2. Petición con campo de título faltante (`undefined` / omitido):
```javascript
test('rejects task creation with a missing title field (400)', async () => {
  const token = await createTestUserAndGetToken();
  const response = await request(app)
    .post('/api/v1/tasks')
    .set('Authorization', `Bearer ${token}`)
    .send({}); // payload vacío sin título
  expect(response.status).toBe(400);
});
```

### 3. Usuario intentando actualizar la tarea de otro usuario:
```javascript
test('rejects a user attempting to update another user task (403)', async () => {
  const owner = await createTestUserAndGetToken('alice@example.test');
  const stranger = await createTestUserAndGetToken('bob@example.test');
  const taskId = await createTask(owner, 'Alice secret project');

  const response = await request(app)
    .put(`/api/v1/tasks/${taskId}`)
    .set('Authorization', `Bearer ${stranger}`)
    .send({ title: 'Tampered title' });

  expect([403, 404]).toContain(response.status);
});
```

---

## Inspección Manual con cURL
Para probar el endpoint localmente:
```bash
# Iniciar servidor backend
cd backend
npm start

# Consultar tareas con token de prueba
curl -i http://localhost:3000/api/v1/tasks \
  -H "Authorization: Bearer <LOCAL_TEST_ACCESS_TOKEN>"
```
*Regla de seguridad:* Nunca ingresar tokens reales de producción en capturas ni terminales compartidas.
