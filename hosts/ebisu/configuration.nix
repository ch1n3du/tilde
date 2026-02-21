{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/main-user.nix
    ../../modules/nixos/s3nixcache-mixrank.nix
    ../../modules/nixos/ssh-tunnels.nix
  ];

  tilde.system.hostname = "ch1n3du-ebisu-nixos";
  tilde.system.stateVersion = "24.05";

  # Extra nix settings (on top of common.nix)
  nix.settings.trusted-users = [
    "root"
    "ch1n3du"
  ];
  nix.settings.keep-outputs = true;

  # Disable RP05 wakeup source
  systemd.services.disable-rp05-wakeup = {
    description = "Disable RP05 ACPI wakeup";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo RP05 > /proc/acpi/wakeup'";
    };
  };

  # Enable NVIDIA s2idle power management
  boot.extraModprobeConfig = ''
    options nvidia NVreg_EnableS0ixPowerManagement=1
    options nvidia NVreg_S0ixPowerManagementVideoMemoryThreshold=10000
  '';

  # Runtime PM for NVIDIA GPU
  services.udev.extraRules = ''
    # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

    # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';

  # X11
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  # DNS
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Locale
  i18n.defaultLocale = "en_NG";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NG";
    LC_IDENTIFICATION = "en_NG";
    LC_MEASUREMENT = "en_NG";
    LC_MONETARY = "en_NG";
    LC_NAME = "en_NG";
    LC_NUMERIC = "en_NG";
    LC_PAPER = "en_NG";
    LC_TELEPHONE = "en_NG";
    LC_TIME = "en_NG";
  };
  i18n.extraLocales = [
    "en_US.UTF-8/UTF-8"
    "pt_BR.UTF-8/UTF-8"
  ];

  # Display / Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # User (additional groups/packages on top of common.nix)
  users.users.ch1n3du = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      signal-desktop
      clang
      rustup
      postgresql
    ];
  };

  # Disable GNOME's SSH agent (using home-manager ssh-agent instead)
  services.gnome.gcr-ssh-agent.enable = false;

  # CUDA support
  nixpkgs.config.cudaSupport = true;

  # Extra system packages
  environment.systemPackages = with pkgs; [
    gnupg
    mangohud
    protonup-ng
    lutris
    bottles
    gruvbox-gtk-theme
  ];

  # Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ch1n3du/.steam/root/compatibilitytools.d";
  };

  # Dynamic linking
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libx11
      libxcursor
      libxcb
      libxi
      libxkbcommon
      vulkan-loader
      glfw
      vips
      dive
      podman-tui
      docker-compose
      podman-compose
    ];
  };

  # Docker
  virtualisation.docker.enable = true;

  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };

  # Home Manager
  home-manager.users."ch1n3du" = import ./home.nix;
}
