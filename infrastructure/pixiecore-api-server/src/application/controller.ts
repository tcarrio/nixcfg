import { Hono } from "hono";

export const app = new Hono()

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

app.get('/healthcheck', (c) => {
  return c.json({ success: true });
})
