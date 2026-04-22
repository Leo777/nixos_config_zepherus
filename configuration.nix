# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./default.nix
    ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.initrd.kernelModules = ["amdgpu" "nvidia" "nvidia-drm" "nvidia-modeset"];
  services.power-profiles-daemon.enable = true;
  services.acpid.enable = true;
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_DynamicPowerManagement=0x02"
    "nvidia.NVreg_RegistryDwords=RMHdcpKeyglobZero=1"
    "acpi_enforce_resources=lax"
    "btusb.enable_autosuspend=0"
    "mem_sleep_default=deep"
    "amdgpu.dcdebugmask=0x10"
  ];
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  boot.blacklistedKernelModules = ["nouveau"];
  programs.corectrl.enable = true;
  services.upower.enable = true;
  programs.rog-control-center.enable = true;
  services.logind.settings.Login.KillUserProcesses = true;

  hardware.amdgpu.initrd.enable = lib.mkDefault true;


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixos"; # Define your hostname.
  networking.firewall.allowedTCPPorts = [ 8188 ];
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
  nix.settings.trusted-users = [ "root" "zen" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  fonts.packages = with pkgs; [
  nerd-fonts.fira-code
  nerd-fonts.droid-sans-mono
  nerd-fonts.jetbrains-mono
];
# Enable Docker
  virtualisation.docker = {
    enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;
    # Configure Portainer as a Docker container
  virtualisation.oci-containers.containers = {
    portainer = {
      image = "portainer/portainer-ce:latest"; # Use the latest Portainer community edition
      autoStart = true;                        # Start automatically on boot
      ports = [ "9000:9000" ];                 # Map host port 9000 to container port 9000
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock" # Allow Portainer to manage Docker
        "portainer_data:/data"                      # Persist Portainer data
      ];
    };
  };


  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.wifi.powersave = false;
  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

   # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;
  services.desktopManager.plasma6.enable = true;

  services.udev.packages = [ pkgs.udevil pkgs.udisks2];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.browsedConf = ''
  BrowseDNSSDSubTypes _cups,_print
  BrowseLocalProtocols all
  BrowseRemoteProtocols all
  CreateIPPPrinterQueues All

BrowseProtocols all
    '';
 services.avahi = {
   enable = true;
   nssmdns4 = true;
   openFirewall = true;
  };
# THIS IS THE MISSING PIECE:
  services.printing.drivers = [ 
    pkgs.samsung-unified-linux-driver 
    pkgs.splix
  ];
      # Enable Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
 
 # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  #security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
# Enable network discovery
  #services.gvfs.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zen = {
    isNormalUser = true;
    description = "zen";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
    home = "/home/zen";
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    antigravity
    neovim
    nodejs
    krita
    git
    gcc
    gnumake
    gemini-cli
    python313
    ripgrep
    binutils
    bazecor
    gnutar
    lazygit
    wget
    docker
    fastfetch
    nvidia-container-toolkit
    brightnessctl
    (writeShellScriptBin "panel-brightness" ''
      set -euo pipefail
      if [ "$#" -ne 1 ]; then
        echo "Usage: panel-brightness <N%+|N%-|N%>"
        exit 2
      fi

      exec ${brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set "$1"
    '')
    telegram-desktop
    kitty
    # koodo-reader
    kdePackages.krohnkite
    kdePackages.kcalc
    wl-clipboard
    code-cursor
    opencode
    realvnc-vnc-viewer
    kio-fuse
    obsidian
    ntfs3g
    openrgb
    devenv
    starship
    zsh
    fzf
    hplip
    brave
    vlc
    vscode
    yazi
    ffmpeg_6-full
    libvdpau
    libva
    lmstudio
    x264
    figma-linux
    x265
    mdadm
    kdePackages.partitionmanager
    qbittorrent
    asusctl
    libreoffice-qt6-fresh
    usbutils
    unetbootin
    protonup-ng
    mangohud
    vulkan-tools
    pciutils
    protontricks
    tmux
 ];

  # nixpkgs.overlays = [
    # (self: super: {
      # lmstudio = import /home/zen/packages/lmstudio/default.nix { pkgs = super; };
      # davinci-resolve-studio = import /home/zen/packages/davinchi/davinci-resolve-patched.nix { pkgs = super; };
      # Add this line:
      # goose-cli = (builtins.getFlake "/home/zen/projects/goose").defaultPackage.${self.system};
  # ];



  programs.zsh.enable = true;
  programs.kdeconnect.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.direnv.enable = true;
  programs.nix-ld.enable = true;
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;  # Optional: For Steam Remote Play
  dedicatedServer.openFirewall = true;  # Optional: For dedicated servers
};
  programs.steam.package = pkgs.steam.override { extraLibraries = pkgs: [ pkgs.xorg.libX11 ]; };
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  NIXOS_OZONE_WL = "1";
  KWIN_DRM_NO_AMS = "1";
  
  };

 programs.ssh = {
    startAgent = true;
    # Optional: add your keys to automatically load them
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  
  systemd.services.supergfxd.path = [pkgs.kmod pkgs.pciutils];
  services.supergfxd = {
    enable = true;
    settings = {
      vfio_enable = true;
      vfio_save = false;
      always_reboot = false;
      no_logind = false;
      logout_timeout_s = 20;
      hotplug_type = "None";
    };
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
services.udev.extraRules = ''
# Dygma Defy keyboard
SUBSYSTEM=="tty", ATTRS{idVendor}=="35ef", ATTRS{idProduct}=="0012", MODE="0666", GROUP="dialout"
# Prevent NVIDIA GPU from entering D3 cold (fixes HDMI hotplug freeze)
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", ATTR{power/control}="on"
''; 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
