import { Hono } from "hono";

const app = new Hono()

app.use(async (c, next) => {
  injector.into(c);
  next();
});

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

app.get('/healthcheck', (c) => {
  return c.json({ success: true });
})

app.get('/v1/boot/:mac', (c) => {
  return c.json({
    // the URL of the kernel to boot.
    kernel: '',
    // (list of strings): URLs of initrds to load. The kernel will flatten all the initrds into a single filesystem.
    initrd: [], 
    // commandline parameters for the kernel. The commandline is processed by Go's text/template library. Within the template, a URL function is available that takes a URL and rewrites it such that Pixiecore proxies the request.
    cmdline: '',
    // A message to display before booting the provided configuration. Note that displaying this message is on a best-effort basis only, as particular implementations of the boot process may not support displaying text.
    message: '',
  });
});

export {
  app,
  injector,
}