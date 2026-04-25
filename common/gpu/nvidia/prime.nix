{ config, lib, pkgs, ... }:

# This creates a new 'nvidia-offload' program that runs the application passed to it on the GPU
# As per https://nixos.wiki/wiki/Nvidia
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {

environment.systemPackages = [
    nvidia-offload
  ];

hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
    modesetting.enable = true;
    nvidiaPersistenced = true;
    forceFullCompositionPipeline = false;
    dynamicBoost.enable = false;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      amdgpuBusId = "PCI:65:00:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver       # Video Decode for Nvidia
      libva-vdpau-driver
      rocmPackages.clr
    ];
    extraPackages32 = with pkgs; [
      # ROCm generally does not support 32-bit, so leave this empty
    ];
  };
  }
