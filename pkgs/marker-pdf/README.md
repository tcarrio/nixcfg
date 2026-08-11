# marker-pdf

Packages [marker](https://github.com/datalab-to/marker) — converts PDF (and, with
`withFull`, DOCX/PPTX/XLSX/EPUB/HTML/images) to **markdown / JSON / HTML /
chunks**.

Built with [uv2nix](https://pyproject-nix.github.io/uv2nix/), like `serena` and
`endcord`. It builds the marker venv, then re-wraps the runnable CLIs so the
surya inference backend can find `llama-server`.

## How llama.cpp fits in (marker 2.x)

Marker 2 runs the **surya VLM** (layout / OCR / tables) behind a local inference
**server**. On macOS (MPS) and CPU-only Linux, surya auto-selects the `llamacpp`
backend and spawns the upstream `llama-server` binary — it locates it via
`shutil.which("llama-server")`, or an absolute path in `LLAMA_CPP_BINARY`
(`surya/inference/backends/llamacpp.py`). The surya GGUF model auto-downloads
from Hugging Face Hub (`datalab-to/surya-ocr-2-gguf`) on first run.

So **"backed by llama.cpp" just means making `llama-server` discoverable.**
llama.cpp is a **runtime-only** dependency — the venv build never needs it.

### Providing `llama-server`

`llamaCpp` is overridable; the default is **platform-aware**:

| Platform | Default `llamaCpp` | `llama-server` comes from |
| --- | --- | --- |
| macOS (`*-darwin`) | `null` | your `brew install llama.cpp` on `PATH` |
| Linux | `pkgs.llama-cpp` | bundled in the package closure |

When a llama.cpp is bundled, the wrapper pins `LLAMA_CPP_BINARY` to its
`llama-server` (via `--set-default`, so your env still wins).

Overrides:

```nix
# Bundle nix llama-cpp everywhere (self-contained on macOS too)
marker-pdf.override { llamaCpp = pkgs.llama-cpp; }

# Always external — you provide llama-server (brew / PATH / a running server)
marker-pdf.override { llamaCpp = null; }
```

To skip spawning entirely and talk to an already-running server, set
`SURYA_INFERENCE_URL` (see below) — then no local binary is needed at all.

## Building

```bash
nix build .#marker-pdf            # this host
nix build .#packages.x86_64-linux.marker-pdf
nix build .#packages.aarch64-darwin.marker-pdf
```

## Running

```bash
# Single PDF → markdown (the main use case)
nix run .#marker-pdf -- single input.pdf --output_dir ./out

# Batch a whole folder
nix run .#marker-pdf -- marker ./pdfs --output_dir ./out

# Useful flags
#   --output_format {markdown,json,html,chunks}   (json/chunks are great for LLM ingestion)
#   --force_ocr               treat the PDF as scanned / image-only
#   --use_llm --llm_service {claude,gemini,openai,ollama,...}  LLM-assisted refinement
#   --workers N               batch parallelism
```

If installed to a profile, the CLIs are `marker` and `marker_single`.

> **Scope:** only `marker` and `marker_single` are wrapped. `marker_gui`
> (Streamlit) and `marker_server` (FastAPI) live in the `dev` dependency-group
> (which also drags in playwright/jupyter/pytest), so they are not built by
> default.

## Variants

```nix
# Non-PDF formats (DOCX/PPTX/XLSX/EPUB/HTML) via the [full] extra
marker-pdf.override { withFull = true; }
```

## Runtime data location (read-only store workaround)

marker computes its data dir (`BASE_DIR`) as the parent of the installed
package — i.e. inside the read-only Nix store — then downloads the GoNoto font
into `FONT_DIR` there at runtime, which would fail with `PermissionError`.

This package patches `BASE_DIR` to a **writable per-user** location, overridable
with `MARKER_DATA_DIR` (default `~/.local/share/marker`). That is where the font
and (if you omit `--output_dir`) conversion outputs land. The surya GGUF model
and HF weights still cache under `~/.cache` as upstream intends.

## Relevant environment variables

Surya inference backend (the llama.cpp path):

- `LLAMA_CPP_BINARY` — path/name of `llama-server` (wrapper sets this when bundled)
- `LLAMA_CPP_NGL` — GPU layers to offload (default `99`; harmless on pure-CPU builds)
- `LLAMA_CPP_EXTRA_ARGS` — extra flags forwarded to `llama-server`
- `SURYA_INFERENCE_BACKEND` — `llamacpp` | `vllm` (auto: `llamacpp` on MPS/CPU, `vllm` on CUDA)
- `SURYA_INFERENCE_URL` — point at an external server instead of spawning one
- `SURYA_INFERENCE_PARALLEL` / `SURYA_INFERENCE_KEEP_ALIVE` — concurrency / lifetime
- `SURYA_GGUF_LOCAL_MODEL_PATH` / `SURYA_GGUF_LOCAL_MMPROJ_PATH` — pin local GGUFs (skip HF download)

## Wiring it into a profile

Add it to a Home Manager package list to get `marker`/`marker_single` on `PATH`:

```nix
home.packages = [ inputs.self.packages.${system}.marker-pdf ];
```

On macOS, make sure `llama-server` is reachable (the default assumes
`brew install llama.cpp`), e.g. keep `/opt/homebrew/bin` on your shell `PATH` or
override `llamaCpp = pkgs.llama-cpp;`.

## Updating

1. Bump `version` and `rev = "v${version}"` in `default.nix`.
2. Refresh the source hash:
   ```bash
   nix-prefetch-url --unpack https://github.com/datalab-to/marker/archive/refs/tags/vX.Y.Z.tar.gz
   nix hash to-sri --type sha256 <hash>
   ```
3. If the build fails on a native dep, add a wheel/sdist fixup to the
   `pythonSet` overlay (see the uv2nix [overriding docs](https://pyproject-nix.github.io/uv2nix/)).
