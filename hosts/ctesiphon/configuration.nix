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
    ../../modules/nixos/s3nixcache-mixrank.nix
  ];

  tilde.system.hostname = "ctesiphon";
  tilde.system.stateVersion = "25.11";

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Btrfs options
  fileSystems."/".options = [
    "compress=zstd"
    "noatime"
  ];
  services.btrfs.autoScrub.enable = true;

  # Extra nix settings (on top of common.nix)
  nix.settings.trusted-users = [
    "root"
    "ch1n3du"
  ];
  nix.settings.keep-outputs = true;

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
  hardware.graphics.enable = true;

  # User
  users.users.ch1n3du = {
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Disable GNOME's SSH agent (using home-manager ssh-agent instead)
  services.gnome.gcr-ssh-agent.enable = false;

  # Swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB
    }
  ];

  # Home Manager
  home-manager.users."ch1n3du" = import ./home.nix;
}
