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
  imports = [ ./. ];

  environment.systemPackages = [ nvidia-offload ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
  package = config.boot.kernelPackages.nvidiaPackages.beta;

  open = true;

   # Additional recommended settings
  modesetting.enable = true;
  powerManagement.enable = true;
  powerManagement.finegrained = true;
  prime = {
    offload.enable = lib.mkForce true;
    #sync.enable = lib.mkForce true;
    # Hardware should specify the bus ID for intel/nvidia devices

    };
  };
}
