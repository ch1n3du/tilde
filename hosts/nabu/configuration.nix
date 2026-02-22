{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/s3nixcache-mixrank.nix
  ];

  tilde.system.hostname = "nabu";
  tilde.system.stateVersion = "24.11";

  # btrfs config options + swap
  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/home".neededForBoot = true;
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/swap".options = [ "noatime" ];
  };

  services.btrfs.autoScrub.enable = true;
  swapDevices = [ { device = "/swap/swapfile"; } ];

  boot.loader.efi.canTouchEfiVariables = true;

  # X11 / GNOME
  services.xserver.enable = false;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

  # User (additional settings on top of common.nix)
  users.users.ch1n3du = {
    hashedPassword = "$6$mc76ZmffXvKgvxMU$vS2FXwqNuktcg6NyIaaWm//GdqBgGIm0MIj6sYn4P8zguHgmdbjYBfQV0TmyP3s02D2cu7Vl5/vhUqYyYM6TT/";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
      git
      tree
      atuin
      neofetch
      hollywood
      ranger
      firefox
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0UOsoyI9F/mnD0x/wyfCmXD1H7FYvhbgwh1foielMf ch1n3du@ch1n3du-ebisu-nixos"
    ];
  };

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;

  # Extra system packages
  environment.systemPackages = with pkgs; [
    vim
    curl
    dnsutils
    pciutils
    usbutils
    inetutils
    file
    xclip
    nix-search-cli
    _7zz
  ];

  # SSH (extra settings on top of common.nix)
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  # Reverse proxy
  services.caddy = {
    enable = true;
    virtualHosts = {
      "deluge.nabu.local".extraConfig = ''
        reverse_proxy http://nabu.local:8112
      '';
      "jellyfin.nabu.local".extraConfig = ''
        reverse_proxy http://localhost:8096
      '';
      "jellyseer.nabu.local".extraConfig = ''
        reverse_proxy nabu.local:5055
      '';
      "sonarr.nabu.local".extraConfig = ''
        reverse_proxy nabu.local:8989
      '';
      "radarr.nabu.local".extraConfig = ''
        reverse_proxy nabu.local:7878
      '';
    };
  };

  # Deluge
  services.deluge = {
    declarative = true;
    enable = true;
    openFirewall = true;
    dataDir = "/media";
    authFile = pkgs.writeTextFile {
      name = "deluge-auth";
      text = ''
        localclient::10
        ch1n3du:password:10
      '';
    };
    web = {
      enable = true;
      openFirewall = true;
    };
    config = {
      max_upload_speed = "1000.0";
      share_ratio_limit = "2.0";
      allow_remote = true;
      enabled_plugins = [ "Label" ];
    };
  };

  # /media permissions
  systemd.tmpfiles.settings = {
    "10-make-media-folder-uwu" = {
      "/media" = {
        d = {
          group = "root";
          mode = "0777";
          user = "root";
        };
      };
    };
  };

  # Media services
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "ch1n3du";
  };
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  # Arr suite
  services.radarr = {
    enable = true;
    openFirewall = true;
    settings = { };
  };
  services.sonarr = {
    enable = true;
    openFirewall = true;
    settings = { };
  };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = { };
  };

  # Home Manager
  home-manager.users."ch1n3du" = import ./home.nix;
}
