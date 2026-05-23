{ config, pkgs, lib, ... }:

{
  services.llama-cpp = {
    enable = true;
    package = (pkgs.llama-cpp.override {
      cudaSupport = true;
    });

    extraFlags = [
      "--ngl 999"
      "--tensor-split blk\.([0-9]|1[0-9]|2[0-9])\.=CUDA0,exps=CPU"
      "--batch-size 4096"
      "--ubatch-size 4096"
      "--ctx-size 32768"
      "--threads 16"
      "--flash-attn"
      "--no-mmap"
    ];

    # Model presets - GGUF format MoE models
    modelsPreset = {
      # Qwen3-MoE series - good starting point
      "Qwen3-MoE-A2B" = {
        hf-repo = "Qwen/Qwen3-MoE-GGUF";
        hf-file = "qwen3moe-a2b-q4_k_m.gguf";
        alias = "qwen3moe-a2b";
        temp = "1.0";
        top-p = "0.95";
        top-k = "40";
      };

      # DeepSeek V3 MoE - larger but excellent performance
      # "deepseek-v3-671b" = {
      #   hf-repo = "deepseek-ai/DeepSeek-V3-GGUF";
      #   hf-file = "DeepSeek-V3-671B-A37B-Q4_K_M.gguf";
      #   alias = "deepseek-v3-671b";
      #   temp = "1.0";
      #   top-p = "0.95";
      #   top-k = "40";
      # };

      # GLM-4.7 MoE
      # "glm-4.7-moe" = {
      #   hf-repo = "THUDM/GLM-4.7-MoE-GGUF";
      #   hf-file = "glm-4.7-moe-q4_k_m.gguf";
      #   alias = "glm-4.7-moe";
      #   temp = "1.0";
      #   top-p = "0.95";
      #   top-k = "40";
      # };

      # Kimi K2 MoE
      # "kimi-k2-moe" = {
      #   hf-repo = "kimi-ai/Kimi-K2-GGUF";
      #   hf-file = "kimi-k2-moe-q4_k_m.gguf";
      #   alias = "kimi-k2-moe";
      #   temp = "1.0";
      #   top-p = "0.95";
      #   top-k = "40";
      # };
    };
  };

  # Required for shader cache with NVIDIA
  systemd.services.llama-cpp = {
    environment = {
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    };
  };
}
