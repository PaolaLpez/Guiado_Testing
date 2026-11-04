'use strict';

const { app } = require('./src/app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Task Manager API running at http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Tasks endpoint: http://localhost:${PORT}/api/v1/tasks`);
});
