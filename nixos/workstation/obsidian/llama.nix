{ config, pkgs, lib, ... }:

let
  pkgs' = pkgs.unstable;
  cudaPackages = pkgs'.cudaPackages_12;
  inherit (cudaPackages) cudatoolkit;

  # Use upstream llama-cpp from nixpkgs-unstable with CUDA CC 6.1 support
  package = pkgs'.llama-cpp.overrideAttrs (old: {
    cudaSupport = true;
    inherit cudaPackages;
    cmakeFlags = (old.cmakeFlags or []) ++ [
      "-DCMAKE_CUDA_ARCHITECTURES=61"
      "-DCMAKE_CUDA_COMPILER_TOOLKIT=${cudatoolkit}/bin"
    ];
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ cudatoolkit ];
  });
in
{
  environment.systemPackages = [package];

  services.llama-cpp = {
    enable = false;

    inherit package;

    model = "/home/tcarrio/.local/share/llama-cpp/models/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";

    extraFlags = [
      "--n-gpu-layers" "10"
      "--ctx-size" "8192"
      "--threads" "8"
      "--no-mmap"
    ];

    # Model presets - GGUF format MoE models
    # modelsPreset = {
    #   # Qwen3-MoE series - good starting point
    #   "Qwen3-MoE-A2B" = {
    #     hf-repo = "Qwen/Qwen3-MoE-GGUF";
    #     hf-file = "qwen3moe-a2b-q4_k_m.gguf";
    #     alias = "qwen3moe-a2b";
    #     temp = "1.0";
    #     top-p = "0.95";
    #     top-k = "40";
    #   };
    #
    #   # DeepSeek V3 MoE - larger but excellent performance
    #   "deepseek-v3-671b" = {
    #     hf-repo = "deepseek-ai/DeepSeek-V3-GGUF";
    #     hf-file = "DeepSeek-V3-671B-A37B-Q4_K_M.gguf";
    #     alias = "deepseek-v3-671b";
    #     temp = "1.0";
    #     top-p = "0.95";
    #     top-k = "40";
    #   };
    #
    #   # GLM-4.7 MoE
    #   "glm-4.7-moe" = {
    #     hf-repo = "THUDM/GLM-4.7-MoE-GGUF";
    #     hf-file = "glm-4.7-moe-q4_k_m.gguf";
    #     alias = "glm-4.7-moe";
    #     temp = "1.0";
    #     top-p = "0.95";
    #     top-k = "40";
    #   };
    #
    #   # Kimi K2 MoE
    #   "kimi-k2-moe" = {
    #     hf-repo = "kimi-ai/Kimi-K2-GGUF";
    #     hf-file = "kimi-k2-moe-q4_k_m.gguf";
    #     alias = "kimi-k2-moe";
    #     temp = "1.0";
    #     top-p = "0.95";
    #     top-k = "40";
    #   };
    # };
  };

  # Required for shader cache with NVIDIA
  systemd.services.llama-cpp = {
    environment = {
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    };
  };
}
