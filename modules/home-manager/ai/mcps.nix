{ config, pkgs, lib, ... }:
let
  cfg = config.oxc.ai.mcps;
  inherit (lib) optional mkEnableOption mkOption types;
  inherit (lib.attrsets) optionalAttrs;

  mcpdoc-wrapper-vercel-ai = mcpdoc-wrapper-of "vercel-ai" {
    "Vercel AI SDK" = "https://sdk.vercel.ai/llms.txt";
  };

  mcpdoc-wrapper-effect = mcpdoc-wrapper-of "effect" {
    "Effect" = "https://effect.website/llms.txt";
  };

  ### GitHub MCP ###
  # The githubMcpServer package wrapper relies on auth context provided
  # by the github CLI, accessed from the user PATH as opposed to a Nix
  # store path. This ensures a simple process to authenticate to the MCP
  # server when necessary.
  githubMcpServer = pkgs.writeShellScript "github-mcp-server" ''
    if ! command -v gh; then
      echo "Error: github-cli not installed!" >&2
      exit 2
    fi

    GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)"
    if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
      echo "Error: github-cli is not authenticated!" >&2
      exit 3
    fi

    export GITHUB_PERSONAL_ACCESS_TOKEN

    ${cfg.servers.github.pkg}/bin/github-mcp-server \
      --dynamic-toolsets \
      --read-only \
      "$@"
  '';

  ### llms.txt doc wrappers ###
  # Provides utility wrapping of llms.txt resources online behind a
  # local Python server to fulfill an MCP server with more interactive
  # documentation access targeted at LLM consumption.
  mcpdoc-wrapper-of = name: projectUrlMap:
    let
      urlArgs = builtins.concatStringsSep " " (
        builtins.map (name: ''"${name}:${projectUrlMap.${name}}"'')
          (builtins.attrNames projectUrlMap)
      );
    in
    pkgs.writeScript "mcpdoc-wrapper-${name}" ''
      exec ${pkgs.uv}/bin/uvx --from mcpdoc mcpdoc \
        --urls \
        ${urlArgs} \
        --transport stdio \
        "$@"
    '';
  llmWrappers = lib.mapAttrs' (name: { url, title }:
    let
      mcpdoc-wrapper = mcpdoc-wrapper-of name {
        "${title}" = url;
      };
    in lib.nameValuePair name {
      command = "${mcpdoc-wrapper}";
    });

  ### MCP Server configuration file ###
  mcpJsonText = builtins.toJson {
    inherit mcpServers;
  };
  mcpServers = {}
    // (optionalAttrs cfg.servers.llms-docs.enable llmWrappers)
    // (optionalAttrs cfg.servers.github.enable {
      github = {
        command = "${githubMcpServer}/bin/github-mcp-server";
      };
    })
    // (optionalAttrs cfg.servers.serena.enable {
      serena = {
        command = "${cfg.serena.pkg}/bin/serena start-mcp-server";
      };
    });

  packages = []
    # // (optional cfg.serena.enable cfg.serena.pkg)
    # // (optional cfg.github.enable githubMcpServer);
    ;
in
{
  options.oxc.ai.mcps = {
    targets = {
      default = mkOption {
        type = types.bool;
        default = true;
        description = "Enables the ~/.mcp.json output config file";
      };
      cursor = mkEnableOption "Enables the ~/.cursor/mcp.json output config file for Cursor";
      codex = mkEnableOption "Enables the ~/.codex/mcp.json output config file for Codex";
      claude = mkEnableOption "Enables the ~/.codex/mcp.json output config file for Claude";
    };
    servers = {
      llms-docs = {
        enable = mkEnableOption "Enables mcpdoc wrapping of various llms.txt site resources";
        sources = lib.mkOption {
          type = types.attrset;
          default = {};
          description = "Map of various llms.txt sites. Keys are used for mcp.json keys, values are transformed into mcpdoc wrapper.";
        };
      };
      github = {
        enable = mkEnableOption "Enables the github-mcp-server integration";
        pkg = mkOption {
          type = types.package;
          default = pkgs.unstable.github-mcp-server;
          description = "The package to use for the github-mcp-server. Will invoke $pkg/bin/github-mcp-server";
        };
      };
      serena = {
        enable = mkOption {
          type = types.bool;
          default = lib.mkDefault config.ai.serena.enable;
          description = "Enables the serena MCP server integration";
        };
        pkg = mkOption {
          type = types.package;
          default = pkgs.unstable.serena;
          description = "The package to use for the Serena MCP server. Will invoke $pkg/bin/serena";
        };
      };
    };
  };

  config = {
    home.packages = packages;
  }
  // (optionalAttrs cfg.targets.default.enable {
    home.file.".mcp.json".text = mcpJsonText;
  })
  // (optionalAttrs cfg.targets.cursor.enable {
    home.file.".cursor/mcp.json".text = mcpJsonText;
  });
}
