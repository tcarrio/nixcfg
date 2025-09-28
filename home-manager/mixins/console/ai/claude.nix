{ pkgs, ... }:
let 
  mcpdoc-wrapper-of = name: projectUrlMap: 
    let
      urlArgs = builtins.concatStringsSep " " (
        builtins.map (name: ''"${name}:${projectUrlMap.${name}}"'') 
        (builtins.attrNames projectUrlMap)
      );
    in
    pkgs.writeShellScriptBin "mcpdoc-wrapper-${name}" ''
      exec ${pkgs.uv}/bin/uvx --from mcpdoc mcpdoc \
        --urls \
        ${urlArgs} \
        --transport stdio \
        "$@"
    '';

  mcpdoc-wrapper-vercel-ai = mcpdoc-wrapper-of "vercel-ai" {
    "Vercel AI SDK" = "https://sdk.vercel.ai/llms.txt";
  };

  mcpdoc-wrapper-effect = mcpdoc-wrapper-of "effect" {
    "Effect" = "https://effect.website/llms.txt";
  };

in {
  home.packages = [
    pkgs.unstable.claude-code

    # MCP Servers
    mcpdoc-wrapper-vercel-ai
    mcpdoc-wrapper-effect
  ];
  
  home.file.".mcp.json".text = builtins.toJSON {
    mcpServers = {
      vercel_ai_sdk_docs = {
        command = "${mcpdoc-wrapper-vercel-ai}/bin/mcpdoc-wrapper-vercel-ai";
        args = [];
      };
      effect_docs = {
        command = "${mcpdoc-wrapper-effect}/bin/mcpdoc-wrapper-effect";
        args = [];
      };
    };
  };
}
