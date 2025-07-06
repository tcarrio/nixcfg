# tailscale-exit-node

Fly.io and Tailscale Docker container setup for fast exit node deploys.

## Initializing

```
fly launch
```

Follow the instructions to select the size, region, etc.

## Configuring

Besides the common configurations for environment variables in `fly.toml`, also make sure to set a Tailscale auth key for the app.

An easy approach is to create a `.secrets` file, and import the secrets with `cat .secrets | fly secrets import`

## Deploying

```
flyctl deploy --ha=false
```

Setting `ha=false` ensures only 1 machine is started for the app.

## Launching new regions

```
fly scale count 1 -r $region
```

See a full list of regions at https://fly.io/docs/reference/regions/.
