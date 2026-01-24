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
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;
  boot.initrd.kernelModules = ["amdgpu" "nvidia" "nvidia-drm" "nvidia-modeset"];
  services.power-profiles-daemon.enable = true;
  services.acpid.enable = true;
  boot.kernelParams = ["nvidia-drm.modeset=1" "mem_sleep_default=deep" "amdgpu.dcdebugmask=0x10"];
  services.fwupd.enable = true;
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


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
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
  #services.xserver.videoDrivers = ["amdgpu"];
  #services.xserver.displayManager.lightdm.enable = true;
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
  #services.blueman.enable = true;
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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
   # media-session.enable = true;
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
    #  thunderbird
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
    gimp
    krita
    git
    gcc
    gnumake
    gemini-cli
    ripgrep
    binutils
    bazecor
    gnutar
    lazygit
    wget
    # davinci-resolve-studio
    docker
    neofetch
    nvidia-container-toolkit
    brightnessctl
    telegram-desktop
    kitty
    # koodo-reader
    python311
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
    yazi
    ffmpeg_6-full
    libvdpau
    libva
    lmstudio
    x264
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
    # goose-cli
    # goose-desktop
    tmux
 ];

  # nixpkgs.overlays = [
    # (self: super: {
      # lmstudio = import /home/zen/packages/lmstudio/default.nix { pkgs = super; };
      # davinci-resolve-studio = import /home/zen/packages/davinchi/davinci-resolve-patched.nix { pkgs = super; };
      # Add this line:
      # goose-cli = (builtins.getFlake "/home/zen/projects/goose").defaultPackage.${self.system};
 #      # NEW: The Desktop App overlay
 # goose-desktop = let
 #        srcPath = "/home/zen/projects/goose/ui/desktop/out/Goose-linux-x64";
 #        libPath = super.lib.makeLibraryPath (with super; [
 #          glib
 #          nss
 #          nspr
 #          atk
 #          at-spi2-atk    # Make sure this uses hyphens, not underscores
 #          dbus
 #          gdk-pixbuf
 #          gtk3
 #          pango
 #          cairo
 #          xorg.libX11
 #          xorg.libXcomposite
 #          xorg.libXdamage
 #          xorg.libXext
 #          xorg.libXfixes
 #          xorg.libXrandr
 #          xorg.libxcb
 #          alsa-lib
 #          cups
 #          expat
 #          mesa
 #        ]);
 #      in super.runCommand "goose-desktop" { } ''
 #        mkdir -p $out/bin $out/share/applications
 #
 #        # Wrapper script
 #        cat > $out/bin/goose-desktop <<EOF
 #        #!/bin/sh
 #        export LD_LIBRARY_PATH=${libPath}:\$LD_LIBRARY_PATH
 #        exec ${super.stdenv.cc.bintools.dynamicLinker} ${srcPath}/Goose "\$@"
 #        EOF
 #
 #        chmod +x $out/bin/goose-desktop
 #
 #        # Desktop Entry
 #        cat > $out/share/applications/goose.desktop <<EOF
 #        [Desktop Entry]
 #        Name=Goose
 #        Exec=$out/bin/goose-desktop --no-sandbox
 #        Icon=${srcPath}/resources/app/src/images/icon.png
 #        Type=Application
 #        Categories=Development;
 #        EOF
 #      '';    })
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
  
  # Helps with mouse cursor lag on some setups
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
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  
  systemd.services.supergfxd.path = [pkgs.kmod pkgs.pciutils];
  services.supergfxd = {
    enable = true;
    settings = {
      vfio_enable = true;
      vfio_save = false;
      always_reboot = false;
      no_logind = false;
      logout_timeout_s = 20;
      hotplug_type = "Asus";
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
''; 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
