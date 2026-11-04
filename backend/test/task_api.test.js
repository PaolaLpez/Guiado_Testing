'use strict';

const request = require('supertest');
const jwt = require('jsonwebtoken');
const { app, db, resetDb, JWT_SECRET } = require('../src/app');

// Helpers for test setup
async function createTestUserAndGetToken(email = `user-${Math.random()}@example.test`) {
  const userId = `user-${Buffer.from(email).toString('hex').slice(0, 8)}`;
  return jwt.sign({ id: userId, email }, JWT_SECRET, { expiresIn: '1h' });
}

async function createTask(token, title = 'Test task') {
  const response = await request(app)
    .post('/api/v1/tasks')
    .set('Authorization', `Bearer ${token}`)
    .send({ title });
  return response.body.id;
}

describe('task API security and integration (Section 6 & 9)', () => {
  beforeEach(() => {
    resetDb();
  });

  test('rejects task creation without authentication', async () => {
    const response = await request(app)
      .post('/api/v1/tasks')
      .send({ title: 'Plan tests' });
    expect(response.status).toBe(401);
  });

  test('rejects an empty title', async () => {
    const token = await createTestUserAndGetToken();
    const response = await request(app)
      .post('/api/v1/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: ' ' });
    expect(response.status).toBe(400);
  });

  test('does not let one user read another user task', async () => {
    const owner = await createTestUserAndGetToken('owner@example.test');
    const stranger = await createTestUserAndGetToken('stranger@example.test');
    const taskId = await createTask(owner, 'Private task');

    const response = await request(app)
      .get(`/api/v1/tasks/${taskId}`)
      .set('Authorization', `Bearer ${stranger}`);
    expect([403, 404]).toContain(response.status);
  });

  // Practice exercises (Section 6):
  test('rejects an invalid / non-existent task ID with 404', async () => {
    const token = await createTestUserAndGetToken();
    const response = await request(app)
      .get('/api/v1/tasks/non-existent-task-id-999')
      .set('Authorization', `Bearer ${token}`);
    expect(response.status).toBe(404);
  });

  test('rejects task creation with a missing title field (400)', async () => {
    const token = await createTestUserAndGetToken();
    const response = await request(app)
      .post('/api/v1/tasks')
      .set('Authorization', `Bearer ${token}`)
      .send({}); // missing title
    expect(response.status).toBe(400);
  });

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

  // Practice exercise (Section 9):
  test('retains server-derived ownership and ignores or rejects client-supplied ownerId on update', async () => {
    const owner = await createTestUserAndGetToken('victim@example.test');
    const originalOwnerId = jwt.decode(owner).id;
    const taskId = await createTask(owner, 'Legitimate task');

    const response = await request(app)
      .put(`/api/v1/tasks/${taskId}`)
      .set('Authorization', `Bearer ${owner}`)
      .send({
        title: 'Updated title safely',
        ownerId: 'malicious-injected-owner-id',
      });

    expect(response.status).toBe(200);

    // Verify database record still retains original owner
    const storedTask = db.tasks.find((t) => t.id === taskId);
    expect(storedTask.ownerId).toBe(originalOwnerId);
    expect(storedTask.ownerId).not.toBe('malicious-injected-owner-id');
  });

  // Health check endpoint verification
  test('health check returns 200 and ok status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });
});
