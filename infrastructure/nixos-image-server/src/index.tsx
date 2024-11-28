import { Context, Hono } from "hono";
import { env } from "hono/adapter";
import { jsxRenderer, useRequestContext } from "hono/jsx-renderer";

const app = new Hono();

function getEnv(c: Context<any>): Env {
  return env(c) as Env;
}

const styles = {
	classes: {
		shadow: {
			boxShadow: '0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19)',
		},
	},
	colors: {
		nix: {
			darker: '#5277c3',
			lighter: '#7eb7e2', 
		}
	}
}

app.get(
  "/",
  jsxRenderer(({ children }) => {
    return (
      <html style="margin: 0; height: 100vh; width:100vw">
        <body style={{margin: 0, height: '100%', width: '100%', backgroundColor: '#444444' }}>
          <div style="height: 100%; display:flex; align-items: center; justify-content: center;">{children}</div>
        </body>
      </html>
    );
  })
);

app.get("/", (c) =>
  c.render(
    <div style={{...styles.classes.shadow, width: 'min(768px, 100vw)', textAlign: 'center', borderRadius: '0.5rem', backgroundColor: styles.colors.nix.darker, color: 'white', display: 'flex', padding: '2rem'}}>
			<aside style={{backgroundColor: 'white', borderRadius: '50%', padding: '2rem'}}>
				<img style="min-width:240px; max-width:240px; min-height:240px" src="https://upload.wikimedia.org/wikipedia/commons/3/35/Nix_Snowflake_Logo.svg"></img>
			</aside>
			<div style={{textAlign: 'center', display: 'flex', flexDirection: 'column', justifyContent: 'center', width: '100%'}}>
      <h1>❄️ nixos image server ❄️</h1>
      <h2>

				<a href="https://github.com/tcarrio/nixcfg.git" style={{color: 'white', textDecoration: 'none'}}>
          github.com/tcarrio/nixcfg
        </a>
      </h2>
			</div>
    </div>
  )
);

app.get("/healthcheck", async (c) => {
  const { IMAGE_BUCKET, TOKEN_SECRET } = getEnv(c);

  const bucketAttached = !!IMAGE_BUCKET;
  const secretConfigured = !!TOKEN_SECRET;

  return c.json({ success: bucketAttached && secretConfigured });
});

app.get("/images/:name", async (c) => {
  const { IMAGE_BUCKET, TOKEN_SECRET } = getEnv(c);

  const { name } = c.req.param();
  const { token } = c.req.query();

  if (token !== TOKEN_SECRET) {
    return c.text("Unauthorized", {
      status: 403,
    });
  }

  const object = await IMAGE_BUCKET.get(name);

  if (object === null) {
    return new Response("Object Not Found", { status: 404 });
  }

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set("etag", object.httpEtag);

  return new Response(object.body, {
    headers,
  });
});

app.get("/images", (c) => {
  return c.text("Method Not Allowed", {
    status: 405,
    headers: {
      Allow: "GET",
    },
  });
});

export default app;
