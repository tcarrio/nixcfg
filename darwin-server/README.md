# Project layout

```
.
├── flake.nix                  # inputs, host assembly, per-host models
├── modules/
│   ├── default.nix            # barrel: imports all modules below
│   ├── base.nix               # oxc.user options, SSH, loginwindow, packages, Nix
│   ├── homebrew.nix           # nix-homebrew + brews (tailscale, llama.cpp)
│   ├── secrets.nix            # agenix identity + secrets
│   ├── firewall.nix           # PF ruleset + boot loader daemon
│   ├── system-tuning.nix      # serverperfmode, no-sleep, gui-teardown
│   ├── tailscale.nix          # tailscaled daemon + activation-time auth
│   ├── hf.nix                 # oxc.hf options + model downloader daemon
│   └── llama.nix              # llama-server daemon (consumes oxc.hf)
└── secrets/
    ├── secrets.nix            # agenix rules: host → public key
    └── tailscale-auth-key.age # encrypted Tailscale auth key
```

Design notes:

- **`oxc.user` options** (in `base.nix`) replace the old top-level `primaryUser`/`primaryUserUid` lets — user identity is now declarative config, overridable per host.
- **`config.homebrew.prefix`** (set explicitly in `homebrew.nix`) replaces the old `brewPrefix` let — every module that needs Homebrew binaries reads it from config.
- **`specialArgs`** carries only the `homebrew-core`/`homebrew-cask` flake inputs into `homebrew.nix` (source trees for pinned taps can't come from config options).
- **Ordering** (launchd has no `After=`/`Requires=`): the downloader retries until success (`KeepAlive.SuccessfulExit = false`); llama-server's wrapper polls for the model file, then `exec`s the server.
- **Tailscale auth** happens at `darwin-rebuild switch` (agenix decrypts → `postActivation` runs `tailscale up`); on reboot `tailscaled` reconnects from persisted state.

# Bootstrap (per machine, with physical access)

1. Install Nix (Determinate Systems installer):
  ```
   curl --proto '=https' --tlsv1.2 -sSf -L \
     https://install.determinate.systems/nix | sh -s -- install
  ```
2. Ensure the SSH host key exists (agenix uses it to decrypt):
  ```
   sudo systemsetup -setremotelogin on
   ls /etc/ssh/ssh_host_ed25519_key   # must exist
  ```
3. Create `secrets/secrets.nix` mapping each host to its SSH host public key (`cat /etc/ssh/ssh_host_ed25519_key.pub`):
  ```nix
   {
     "m1pro" = "ssh-ed25519 AAAA...  host key for m1pro";
     "m4pro" = "ssh-ed25519 AAAA...  host key for m4pro";
   }
  ```
4. Create a Tailscale auth key at [https://login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys), then encrypt it:
  ```
   nix shell github:ryantm/agenix -c agenix -e secrets/tailscale-auth-key.age
  ```
5. Build &amp; switch (models download automatically per host config):
  ```
   nix run nix-darwin -- switch --flake .#m4pro   # or #m4pro
  ```
6. Reboot once so `serverperfmode` takes effect, then verify:
  ```
   ssh tcarrio@m4pro
   tailscale status
   tail -f /var/log/hf-model-downloader.log /var/log/llama-server.log
  ```

---

# flake.nix

Inputs and host assembly. Per-host differences (which model each machine runs) live here, expressed as `oxc.hf.assuredModels` overrides.

```nix
{
  description = "Headless Apple Silicon MacBook server via nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manages the Homebrew installation itself (packages use
    # nix-darwin's homebrew.* options in modules/homebrew.nix).
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Age-encrypted secrets for NixOS and Darwin.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Homebrew tap pinning.
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs:
    let
      inherit (inputs) nix-darwin;

      # Modules shared by every host. ./modules resolves to
      # modules/default.nix (barrel import of all module files).
      commonModules = [
        inputs.nix-homebrew.darwinModules.default
        inputs.agenix.nixosModules.default
        ./modules
      ];

      # Pinned Homebrew tap source trees, consumed by
      # modules/homebrew.nix for declarative tap management.
      specialArgs = {
        homebrew-core = inputs.homebrew-core;
        homebrew-cask = inputs.homebrew-cask;
      };

      mkHost = hostName: extraModules:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit specialArgs;
          modules = commonModules ++ extraModules ++ [{
            networking.hostName = hostName;
            networking.computerName = hostName;
          }];
        };
    in
    {
      darwinConfigurations = {
        # M1 Pro MacBook — 7B class model
        m4pro = mkHost "m4pro" [{
          oxc.hf.assuredModels = [
            {                                # ← example: change me
              repo = "bartowski/Qwen2.5-7B-Instruct-GGUF";
              file = "Qwen2.5-7B-Instruct-Q4_K_M.gguf";
            }
          ];
        }];

        # M4 Pro MacBook — can comfortably run a larger quant
        m4pro = mkHost "m4pro" [{
          oxc.hf.assuredModels = [
            {                                # ← example: change me
              repo = "bartowski/Qwen2.5-14B-Instruct-GGUF";
              file = "Qwen2.5-14B-Instruct-Q4_K_M.gguf";
            }
          ];
        }];
      };

      # Expose the module set for external reuse. Note: reusing it
      # elsewhere requires the same specialArgs (homebrew-core,
      # homebrew-cask).
      darwinModules.headlessServer = ./modules;
    };
}
```

# modules/default.nix

Barrel import — this is what `./modules` in `flake.nix` resolves to.

```nix
{
  imports = [
    ./base.nix
    ./homebrew.nix
    ./secrets.nix
    ./firewall.nix
    ./system-tuning.nix
    ./tailscale.nix
    ./hf.nix
    ./llama.nix
  ];
}
```

# modules/base.nix

User identity options, SSH, login window, system packages, Nix settings.

```nix
{ config, lib, pkgs, ... }:
{
  # ── Primary user identity ─────────────────────────────────────
  # Referenced by homebrew.nix (Homebrew ownership) and
  # system-tuning.nix (GUI teardown). Override per host if needed.
  options.oxc.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "tcarrio";      # ← macOS username
      description = "Primary macOS user account.";
    };
    uid = lib.mkOption {
      type = lib.types.str;
      default = "501";           # ← verify: id -u <username>
      description = "UID of the primary macOS user account.";
    };
  };

  config = {
    # SSH: headless management channel. Enables Apple's built-in
    # sshd as a system daemon; persists across reboots.
    services.openssh.enable = true;

    # No auto-login → no Aqua session created at boot. loginwindow
    # runs but sits near-idle. This is the primary memory-saving
    # mechanism — more effective than killing WindowServer later.
    system.defaults.loginwindow.autoLoginUser = null;
    system.defaults.loginwindow.GuestEnabled = false;
    system.defaults.loginwindow.SleepDisabled = true;

    # System-wide packages in /run/current-system/sw/bin.
    environment.systemPackages = with pkgs; [
      vim
      git
      curl
      htop
      tmux
      wireguard-tools
    ];

    # Homebrew binaries on PATH in non-interactive shells.
    environment.variables.HOMEBREW_PREFIX = config.homebrew.prefix;
    environment.shellInit = ''
      export PATH="${config.homebrew.prefix}/bin:$PATH"
    '';

    nix.extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
    '';
    nix.gc = {
      automatic = true;
      interval = { Hour = 3; Weekday = 0; };  # Sun 03:00
      options = "--delete-older-than 30d";
    };

    system.stateVersion = 4;
  };
}
```

# modules/homebrew.nix

Homebrew installation + declarative package management. Receives the pinned tap trees via `specialArgs` from `flake.nix`.

```nix
{ config, lib, homebrew-core, homebrew-cask, ... }:
{
  # nix-homebrew: manages the Homebrew installation itself.
  nix-homebrew = {
    enable = true;
    enableRosettaBinaries = false;  # Apple Silicon only
    user = config.oxc.user.name;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;  # pin taps to flake inputs
  };

  # nix-darwin homebrew.*: declaratively manages brew packages via
  # `brew bundle` during system activation.
  homebrew = {
    enable = true;
    # Set explicitly so other modules can rely on
    # config.homebrew.prefix. Apple Silicon default; Intel would
    # be /usr/local/Homebrew.
    prefix = "/opt/homebrew";
    onActivation = {
      # "uninstall" removes any brew package not in these lists.
      # Use "none" if you have other Homebrew packages to preserve.
      cleanup = "uninstall";
      upgrade = true;
    };
    brews = [
      # ── Tailscale (formula, NOT cask) ─────────────────────────
      # The cask (tailscale-app) installs a sandboxed Network
      # Extension that requires GUI approval — unusable headless.
      # The formula installs the CLI + tailscaled daemon, which
      # runs as a system daemon with no GUI interaction.
      "tailscale"

      # ── llama.cpp (formula) ───────────────────────────────────
      # Includes llama-server with Metal GPU support on Apple
      # Silicon (unified memory → near-full RAM for inference).
      "llama.cpp"
    ];
    casks = [ ];
  };
}
```

# modules/secrets.nix

agenix configuration. The `.age` path is relative to *this file*, hence `../secrets/`.

```nix
{ ... }:
{
  # agenix decrypts with the SSH host private key during
  # darwin-rebuild switch (activation time).
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets.tailscaleAuthKey = {
    # Create with: agenix -e secrets/tailscale-auth-key.age
    # Decrypted path (evaluated at runtime by the shell):
    #   $(getconf DARWIN_USER_TEMP_DIR)/agenix.d/tailscaleAuthKey
    file = ../secrets/tailscale-auth-key.age;
  };
}
```

# modules/firewall.nix

PF ruleset (declarative file) + boot-time loader daemon. Blocks all inbound; allows loopback, all outbound, SSH (22), and Tailnet (100.64.0.0/10). IP-based rules rather than `utun` interface names because the interface number can change between boots.

```nix
{ lib, pkgs, ... }:
{
  environment.etc."pf.headless-server.conf".text = ''
    # ── Headless MacBook server PF rules ─────────────────────

    # Block all incoming by default
    block in all

    # Allow loopback (local IPC, Nix daemon socket, etc.)
    pass quick on lo0 all

    # Allow all outbound with state tracking (return traffic for
    # established connections is automatically allowed)
    pass out all keep state

    # Allow SSH inbound from anywhere (remote management)
    pass in proto tcp to any port 22

    # Allow all traffic from/to Tailnet (100.64.0.0/10) — covers
    # llama-server, any future services, ICMP, etc.
    pass in quick from 100.64.0.0/10 to any
    pass out quick to 100.64.0.0/10 keep state
  '';

  # Loads the ruleset and enables PF at boot. Runs after Tailscale
  # connects (outbound is allowed), so the VPN can establish even
  # before the firewall is fully up.
  launchd.daemons.pf-firewall = {
    serviceConfig = {
      Program = pkgs.writeShellScript "load-pf" ''
        export PATH=/usr/sbin:/usr/bin:/bin:/sbin
        # Load our ruleset (replaces the entire PF ruleset)
        pfctl -f /etc/pf.headless-server.conf 2>/dev/null || true
        # Enable PF (idempotent — no error if already enabled)
        pfctl -e 2>/dev/null || true
      '';
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
}
```

# modules/system-tuning.nix

macOS boot-time tuning daemons — the settings that have no declarative nix-darwin option. Each runs once at boot (`RunAtLoad`, no `KeepAlive`) and is idempotent.

```nix
{ config, lib, pkgs, ... }:
{
  launchd.daemons = {
    # ── Apple Server Performance Mode ──────────────────────────
    # Sets serverperfmode=1 in NVRAM. Raises kernel limits
    # (maxproc, maxfiles, etc.) and reserves more memory for
    # server workloads. Takes effect on the NEXT reboot.
    serverperfmode = {
      serviceConfig = {
        Program = pkgs.writeShellScript "set-serverperfmode" ''
          export PATH=/usr/sbin:/usr/bin:/bin:/sbin
          if ! nvram boot-args 2>/dev/null | grep -q 'serverperfmode=1'; then
            CURRENT=$(nvram boot-args 2>/dev/null \
              | sed 's/^boot-args[[:space:]]*//')
            nvram boot-args="serverperfmode=1 $CURRENT"
          fi
        '';
        RunAtLoad = true;
        KeepAlive = false;
      };
    };

    # ── No sleep / no hibernate ─────────────────────────────────
    # Essential for a headless MacBook with the lid closed. pmset
    # settings persist in the PMU, but a boot daemon guarantees
    # correctness after an SMC/PRAM reset.
    no-sleep = {
      serviceConfig = {
        Program = pkgs.writeShellScript "no-sleep" ''
          export PATH=/usr/bin:/usr/sbin:/bin:/sbin
          pmset -a sleep 0
          pmset -a hibernatemode 0
          pmset -a standby 0
          pmset -a autopoweroff 0
          pmset -a disablesleep 1
        '';
        RunAtLoad = true;
        KeepAlive = false;
      };
    };

    # ── GUI teardown (optional) ─────────────────────────────────
    # Boots out the per-user Aqua session if one exists. No-op when
    # nobody is logged in (the normal case). Catches someone
    # physically opening the laptop and logging in. Comment out if
    # you want occasional GUI access for maintenance.
    gui-teardown = {
      serviceConfig = {
        Program = pkgs.writeShellScript "gui-teardown" ''
          export PATH=/usr/bin:/bin:/usr/sbin:/sbin
          sleep 15
          launchctl bootout gui/${config.oxc.user.uid} 2>/dev/null || true
        '';
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}
```

# modules/tailscale.nix

`tailscaled` system daemon (always-on) + activation-time authentication. This module owns `postActivation` — if another module later needs activation code, use `lib.mkMerge` or move to `extraActivation` to avoid clobbering.

```nix
{ config, lib, pkgs, ... }:
let
  brewPrefix = config.homebrew.prefix;
in
{
  # tailscaled runs as root (system daemon). It creates a utun
  # interface and maintains the WireGuard tunnel. KeepAlive ensures
  # it restarts if it crashes. State persists at /var/lib/tailscale/
  # so it reconnects automatically after reboot without the auth
  # key — the key is only needed for the FIRST `tailscale up`.
  launchd.daemons.tailscaled = {
    serviceConfig = {
      Program = "${brewPrefix}/bin/tailscaled";
      ProgramArguments = [
        "${brewPrefix}/bin/tailscaled"
        "--statedir=/var/lib/tailscale"
        "--socket=/var/run/tailscale/tailscaled.sock"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/tailscaled.log";
      StandardErrorPath = "/var/log/tailscaled.err.log";
    };
  };

  # Auth flow (runs during darwin-rebuild switch, AFTER agenix has
  # decrypted the secret — the path string contains a shell
  # $(getconf ...) evaluated at runtime):
  #   activation → agenix decrypts key to ephemeral temp dir
  #   → this script reads it → tailscale up --auth-key=...
  #   → key vanishes (temp dir cleared on reboot)
  #   → on reboot, tailscaled reconnects from persisted state
  # If the node is removed from the tailnet admin panel, re-run
  # `darwin-rebuild switch` to re-authenticate.
  system.activationScripts.postActivation.text = ''
    export PATH="${brewPrefix}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    mkdir -p /var/lib/tailscale /var/run/tailscale /var/log

    AUTH_KEY_FILE="${config.age.secrets.tailscaleAuthKey.path}"
    export TS_SOCKET=/var/run/tailscale/tailscaled.sock

    # Wait for tailscaled to be ready (up to 30s)
    for i in $(seq 1 30); do
      if tailscale status >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done

    # Check if already authenticated; if not, authenticate
    if tailscale status 2>&1 | grep -qi "logged out\|not logged in\|no state"; then
      if [ -f "$AUTH_KEY_FILE" ]; then
        AUTH_KEY=$(cat "$AUTH_KEY_FILE" 2>/dev/null)
        if [ -n "$AUTH_KEY" ]; then
          echo "Tailscale: authenticating with auth key..."
          tailscale up --auth-key="$AUTH_KEY" 2>&1 || true
        else
          echo "Tailscale: WARNING — auth key file empty or unreadable"
        fi
      else
        echo "Tailscale: WARNING — auth key file not found at $AUTH_KEY_FILE"
        echo "  (agenix may not have decrypted yet; re-run darwin-rebuild switch)"
      fi
    else
      echo "Tailscale: already authenticated, skipping"
    fi
  '';
}
```

# modules/hf.nix

The `oxc.hf` option namespace + the idempotent model downloader. Idempotent at two layers: checks each file on disk before invoking the CLI, and `huggingface-cli download` itself skips existing blobs. With `--local-dir`, files are moved into place atomically, so the existence check never sees partial downloads. Uses `huggingface-cli` from nixpkgs (pure Python — no GPU concerns — and a hermetic Nix store path is safer than a mutable brew prefix in a boot-critical daemon).

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.oxc.hf;

  hf-cli = "${pkgs.python3Packages.huggingface-hub}/bin/huggingface-cli";
in
{
  options.oxc.hf = {
    modelsDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/llama/models";
      description = "Base directory for downloaded HuggingFace models.";
    };

    assuredModels = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          repo = lib.mkOption {
            type = lib.types.str;
            description = ''
              HuggingFace repo id,
              e.g. "bartowski/Qwen2.5-7B-Instruct-GGUF".
            '';
          };
          file = lib.mkOption {
            type = lib.types.str;
            description = ''
              File within the repo (path relative to repo root),
              e.g. "Qwen2.5-7B-Instruct-Q4_K_M.gguf". The local
              target mirrors this path under modelsDir.
            '';
          };
        };
      });
      default = [ ];
      description = ''
        Models that must be present on disk before llama-server
        starts. The first entry is the model llama-server loads;
        additional entries are downloaded and kept available
        (e.g. draft models for speculative decoding).
      '';
    };
  };

  config.launchd.daemons = lib.mkIf (cfg.assuredModels != [ ]) {
    # Runs at first darwin-rebuild switch (daemons bootstrap during
    # activation) and at every boot. KeepAlive.SuccessfulExit = false
    # means: retry on failure, stay dormant after success — the
    # launchd-native "assured" semantics. To use gated models,
    # extend with an agenix secret and pass
    #   --token "$(cat $HF_TOKEN_FILE)"
    # to the download command.
    hf-model-downloader = {
      serviceConfig = {
        Program = pkgs.writeShellScript "hf-model-downloader" ''
          export PATH=/usr/bin:/bin:/usr/sbin:/sbin
          export HOME=/var/root
          export HF_HOME=/var/lib/huggingface
          MODELS_DIR="${cfg.modelsDir}"
          mkdir -p "$MODELS_DIR" /var/lib/huggingface
          FAILURES=0
        '' + lib.concatMapStringsSep "\n" (m: ''
          TARGET="$MODELS_DIR/${m.file}"
          if [ -f "$TARGET" ]; then
            echo "[hf] ${m.repo}/${m.file}: already present, skipping"
          else
            echo "[hf] ${m.repo}/${m.file}: downloading..."
            if ! ${hf-cli} download "${m.repo}" "${m.file}" \
                --local-dir "$MODELS_DIR"; then
              echo "[hf] ${m.repo}/${m.file}: download FAILED"
              FAILURES=$((FAILURES + 1))
            fi
          fi
        '') cfg.assuredModels + ''
          if [ "$FAILURES" -gt 0 ]; then
            echo "[hf] $FAILURES model(s) failed — exiting nonzero for retry"
            exit 1
          fi
          echo "[hf] all assured models present"
        '';
        RunAtLoad = true;
        # Restart on failure; do NOT restart after successful exit.
        KeepAlive = { SuccessfulExit = false; };
        # Minimum seconds between restarts (backoff for flaky
        # networks / rate limits).
        ThrottleInterval = 30;
        StandardOutPath = "/var/log/hf-model-downloader.log";
        StandardErrorPath = "/var/log/hf-model-downloader.err.log";
      };
    };
  };
}
```

# modules/llama.nix

The llama.cpp API server. Its `Program` is a wrapper that polls for the primary model (downloaded by `hf.nix`), then `exec`s the real `llama-server` — `exec` replaces the shell, so launchd tracks and signals the actual server process. Metal GPU acceleration is automatic on Apple Silicon; `--n-gpu-layers 99` offloads all layers. Listens on `0.0.0.0` but the PF firewall blocks external access — only reachable via Tailnet or SSH port forwarding.

```nix
{ config, lib, pkgs, ... }:
let
  hf = config.oxc.hf;

  # The model llama-server loads: first entry of assuredModels.
  primaryModelPath = "${hf.modelsDir}/${(lib.head hf.assuredModels).file}";

  # API port — promote to an option if you want per-host overrides.
  port = "8080";
in
{
  config.launchd.daemons = lib.mkIf (hf.assuredModels != [ ]) {
    llama-server = {
      serviceConfig = {
        Program = pkgs.writeShellScript "llama-server-wrapper" ''
          export PATH="${config.homebrew.prefix}/bin:/usr/bin:/bin"
          MODEL="${primaryModelPath}"
          echo "[llama-server] waiting for model: $MODEL"
          until [ -f "$MODEL" ]; do
            sleep 5
          done
          echo "[llama-server] model ready, starting server"
          exec ${config.homebrew.prefix}/bin/llama-server \
            --model "$MODEL" \
            --host 0.0.0.0 \
            --port ${port} \
            --n-gpu-layers 99 \
            --cont-batching
        '';
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/llama-server.log";
        StandardErrorPath = "/var/log/llama-server.err.log";
      };
    };
  };
}
```