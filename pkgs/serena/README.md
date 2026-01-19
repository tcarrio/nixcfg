# Serena MCP Server Package

This package builds [Serena](https://github.com/oraios/serena), a coding agent toolkit that turns an LLM into a fully-featured agent working directly on your codebase with semantic code retrieval and editing capabilities.

## Building

```bash
# Build the package
nix build .#serena

# Build for a specific platform
nix build .#packages.x86_64-linux.serena
nix build .#packages.aarch64-darwin.serena
```

## Running

```bash
# Run directly without installing
nix run .#serena -- --help

# Start the MCP server for a project
nix run .#serena -- start-mcp-server --project-root /path/to/your/project
```

## Integration with Claude Code

To use Serena as an MCP server with Claude Code, add it to your MCP configuration:

```json
{
  "mcpServers": {
    "serena": {
      "command": "nix",
      "args": ["run", "/path/to/nixcfg#serena", "--", "start-mcp-server", "--project-root", "/path/to/project"]
    }
  }
}
```

Or if installed to your profile:

```json
{
  "mcpServers": {
    "serena": {
      "command": "serena",
      "args": ["start-mcp-server", "--project-root", "/path/to/project"]
    }
  }
}
```

## Integration with Claude Desktop

Add to your Claude Desktop configuration (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "serena": {
      "command": "nix",
      "args": ["run", "/path/to/nixcfg#serena", "--", "start-mcp-server", "--project-root", "/path/to/project"]
    }
  }
}
```

## Package Details

This package is built using [uv2nix](https://pyproject-nix.github.io/uv2nix/), which converts Python projects managed with `uv` into Nix derivations.

### How it works

1. The source is fetched from GitHub at a pinned version
2. uv2nix loads the `uv.lock` workspace from the source
3. A Python package overlay is created from the lock file
4. A virtual environment is built with all dependencies
5. The `serena` CLI becomes available in the resulting package

### Updating the package

To update to a new version:

1. Update the `rev` in `fetchFromGitHub` to the new tag (e.g., `v0.1.5`)
2. Update the `hash` - you can get this by setting it to an empty string and running the build, or use:
   ```bash
   nix-prefetch-url --unpack https://github.com/oraios/serena/archive/refs/tags/vX.Y.Z.tar.gz
   nix hash to-sri --type sha256 <hash-from-above>
   ```

## Serena Features

Serena provides IDE-like capabilities for LLMs:

- Semantic code retrieval across 30+ programming languages
- Project-aware context management
- Code editing with semantic understanding
- Integration with language servers via multilspy

For full documentation, see the [Serena documentation](https://github.com/oraios/serena).
