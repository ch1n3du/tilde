# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nabu"; # Define your hostname.
  # pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # enables .local, NDNS
  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = false;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ch1n3du = {
    isNormalUser = true;
    hashedPassword = "$6$mc76ZmffXvKgvxMU$vS2FXwqNuktcg6NyIaaWm//GdqBgGIm0MIj6sYn4P8zguHgmdbjYBfQV0TmyP3s02D2cu7Vl5/vhUqYyYM6TT/";
    shell = pkgs.zsh;
    extraGroups = [ 
      "wheel"  # Enable ‘sudo’ for the user.
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0GRtZWrTMZwtk3FBj+w0W39GOlN5SiHQY2wXXbVTEc ch1n3du@ch1n3du-ebisu-nixos"
    ];
  };

  # installing with --no-root-password
  users.mutableUsers = false;

  # zsh
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Setup home-manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = {
      "ch1n3du" = import ./home.nix;
    };
  };

  # programs.firefox.enable = true;

  # enable flakes, garbage collection, optimise storage
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nixpkgs.config.allowUnfree = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    helix
    wget
    curl
    dnsutils  # dig, nslookup
    pciutils  # lspci
    usbutils  # lsusb
    inetutils # whois
    file
    xclip
    nix-search-cli
    _7zz
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    enable = true;

    # Open ports in the firewall.
    # allowedTCPPorts = [ ... ];
    allowedUDPPorts = [ 5353 ];
  };

  # setup a reverse proxy
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
      enabled_plugins = ["Label"];
      # daemon_port = 58846;
    };
  };

  # configure "/media" permissions
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

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "ch1n3du";
  };
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  # arr suite
  services.radarr = {
    enable = true;
    openFirewall = true;
    settings = {};
  };
  services.sonarr = {
    enable = true;
    openFirewall = true;
    settings = {};
  };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {};
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

