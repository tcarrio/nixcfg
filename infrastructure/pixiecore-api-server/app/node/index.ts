import { serve } from '@hono/node-server'

// TODO: Refactor to inject infra
import { app } from '../../src/application/controller.js';

const port = Number.parseInt(process.env.PORT || '3000');

console.log(`Server is running on http://localhost:${port}`);

serve({
  fetch: app.fetch,
  port
});
