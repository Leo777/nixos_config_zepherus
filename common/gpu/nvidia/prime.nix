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
    pkgs.asusctl  # For ROG controls (fans, power profiles, GPU modes)
  ];

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    nvidiaPersistenced = false;
    powerManagement.enable = true;
    powerManagement.finegrained = false;  # Enabled for better efficiency in offload mode
    prime = {
      offload = {
        enable = true;  # Default: Offload for battery optimization
        enableOffloadCmd = true;  # Enables built-in prime-run command
      };
      sync.enable = false;  # Default: Disabled for normal use
      # Hardware bus IDs (verify with lspci | grep -E "VGA|3D")
      amdgpuBusId = "PCI:65:00:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };

  # Enable ASUS daemon for laptop features (fans, LEDs, power)
  services.asusd.enable = true;

  # Enable TLP for advanced power management (battery optimization)
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;  # Disable to avoid conflict with TLP
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";  # Conservative on battery
    CPU_SCALING_GOVERNOR_ON_AC = "performance";  # Aggressive when plugged in
  };

  # Enable video drivers for hybrid setup
  # services.xserver.videoDrivers = [ "modesetting" "amdgpu" "nvidia" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  # Specialisations for mode switching
  specialisation = {
    gaming.configuration = {
      system.nixos.label = "Gaming";  # Label for boot menu
      hardware.nvidia = {
        powerManagement = {
          enable = lib.mkForce false;  # Disable to allow sync (no power down possible)
          finegrained = lib.mkForce false;  # Disable as it requires offload
        };
        prime = {
          sync.enable = lib.mkForce true;  # Force sync for performance
          offload = {
            enable = lib.mkForce false;  # Disable offload
            enableOffloadCmd = lib.mkForce false;  # Disable cmd to satisfy assertion
          };
        };
      };
      # Optional: Boost CPU/GPU for gaming
      services.tlp.settings = lib.mkOverride 1000 {
        CPU_SCALING_GOVERNOR_ON_BAT = "performance";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
      };
    };
  };
}
