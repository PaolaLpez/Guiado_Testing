'use strict';

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const { validateTitle } = require('./tasks/validation');

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'test-secret-key-task-manager-jwt';

// In-memory isolated store for testing
const db = {
  users: [],
  tasks: [],
};

// Reset helper for tests
function resetDb() {
  db.users = [];
  db.tasks = [];
}

// Auth helper middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: Missing or invalid token' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
}

// Health check endpoint (for k6 tests - Section 10)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Login endpoint
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password || password.length < 8) {
    return res.status(400).json({ error: 'Invalid email or password' });
  }

  const userId = `user-${Buffer.from(email).toString('hex').slice(0, 8)}`;
  const accessToken = jwt.sign({ id: userId, email }, JWT_SECRET, { expiresIn: '15m' });
  const refreshToken = jwt.sign({ id: userId, email, type: 'refresh' }, JWT_SECRET, { expiresIn: '7d' });

  res.json({ accessToken, refreshToken, user: { id: userId, email } });
});

// Get user tasks (scoped to owner)
app.get('/api/v1/tasks', authenticateToken, (req, res) => {
  const userTasks = db.tasks.filter((t) => t.ownerId === req.user.id);
  res.json(userTasks);
});

// Create new task
app.post('/api/v1/tasks', authenticateToken, (req, res) => {
  const { title } = req.body || {};
  if (title === undefined || title === null) {
    return res.status(400).json({ error: 'Title is required' });
  }

  let validatedTitle;
  try {
    validatedTitle = validateTitle(title);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }

  const newTask = {
    id: `task-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    title: validatedTitle,
    completed: false,
    ownerId: req.user.id,
    createdAt: new Date().toISOString(),
  };

  db.tasks.push(newTask);
  res.status(201).json(newTask);
});

// Get specific task by ID (OWASP object-level authorization)
app.get('/api/v1/tasks/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const task = db.tasks.find((t) => t.id === id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  // Consistent security policy: prevent disclosing whether another user's task exists
  if (task.ownerId !== req.user.id) {
    return res.status(404).json({ error: 'Task not found' });
  }

  res.json(task);
});

// Update task (validates ownership and ignores client-supplied ownerId)
app.put('/api/v1/tasks/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const task = db.tasks.find((t) => t.id === id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  // Cross-user access check (Section 6 practice)
  if (task.ownerId !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden: Cannot modify another user task' });
  }

  const { title, completed } = req.body || {};

  if (title !== undefined) {
    try {
      task.title = validateTitle(title);
    } catch (err) {
      return res.status(400).json({ error: err.message });
    }
  }

  if (completed !== undefined) {
    task.completed = Boolean(completed);
  }

  // Section 9 practice: client-supplied ownerId is strictly ignored or rejected
  // task.ownerId remains unchanged from req.user.id

  res.json(task);
});

// Delete task
app.delete('/api/v1/tasks/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const index = db.tasks.findIndex((t) => t.id === id);

  if (index === -1) {
    return res.status(404).json({ error: 'Task not found' });
  }

  if (db.tasks[index].ownerId !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  db.tasks.splice(index, 1);
  res.status(204).send();
});

module.exports = { app, db, resetDb, JWT_SECRET };
