{ config, pkgs, lib, ... }:
let
  cfg = config.oxc.services.ollama;
  pkgs' = pkgs.unstable;

  baseConfig = {
    services.ollama = {
      package = lib.mkDefault pkgs'.ollama;
      enable = true;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "${cfg.settings.contextSize}";
      };
    };
  };

  nvidiaConfig = lib.mkIf cfg.hardware == "nvidia" {
    environment.systemPackages = with pkgs'; [
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      cudaPackages.cuda_cudart
    ];

    environment.sessionVariables = {
      CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
      LD_LIBRARY_PATH = lib.makeLibraryPath [
        "${pkgs.cudaPackages.cudatoolkit}"
        "${pkgs.cudaPackages.cudatoolkit}/lib64"
        pkgs.cudaPackages.cudnn
        pkgs.cudaPackages.cuda_cudart
        pkgs.stdenv.cc.cc.lib
      ];
      CUDA_MODULE_LOADING = "LAZY";
    };

    services.ollama = {
      package = pkgs'.ollama-cuda;
      acceleration = "cuda";
      environmentVariables = {
        # Configure CUDA / NVidia access
        CUDA_VISIBLE_DEVICES = "0";
        NVIDIA_VISIBLE_DEVICES = "all";
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };
in
{
  options.oxc.services.ollama = {
    enable = lib.mkEnableOption "Enable the Ollama LLM service";
    hardware = lib.mkOption {
      type = lib.types.enumOf ["nvidia" "cpu"];
      description = "Which hardware to target for hosting the LLM model";
      default = "cpu";
    };
    settings = {
      contextSize = lib.mkOption {
        type = lib.types.int;
        description = "The context size to set up for Ollama models";
        default = 8192;
      };
    };
  };

  config = lib.mkIf cfg.enable (baseConfig // nvidiaConfig);
}