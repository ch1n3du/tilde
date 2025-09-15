{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/main-user.nix
    ../../modules/nixos/s3nixcache-mixrank.nix
    ../../modules/nixos/ssh-tunnels.nix
  ];

  # Test 'main-user' tutorial module options
  # main-user.enable = true;
  # main-user.userName = "ch1n3du2";

  # Use system-d boot
  boot.loader.systemd-boot.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.trusted-users = [ "root" "ch1n3du" ];

  networking.hostName = "ch1n3du-ebisu-nixos"; # Define your hostname.
  services.sshTunnels = {
    enable = true;
    tunnels = [{
      name = "nabu";
      server_hostname = "nabu.local";
      server_port = 8000;
      ssh_username = "ch1n3du";
      local_port = 8000;
      service_user = "ch1n3du";
    }];
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Disable NetworkManager's internal DNS resolution
  # networking.networkmanager.dns = "none";

  # These options are unnecessary when managing DNS ourselves
  # networking.useDHCP = false;
  # networking.dhcpcd.enable = false;

  # Use Cloudflare for DNS resolution
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1" ];

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  # Select internationalisation properties.
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

  # support som extra locales
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Disable wayland
  # services.xserver.displayManager.gdm.wayland = false;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  services.resolved.enable = true;

  # Enable graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable Nvidia settings
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ch1n3du = {
    isNormalUser = true;
    description = "ch1n3du";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      signal-desktop
      clang
      rustup
      postgresql

      # Apps go here
    ];
  };

  # Enable firefox.
  # programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Enable steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Enable dynamic linking
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      xorg.libX11
      xorg.libXcursor
      xorg.libxcb
      xorg.libXi
      libxkbcommon
      xorg.libxcb
      pkgs.vulkan-loader
      pkgs.glfw
      pkgs.vips
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      docker-compose # start group of containers for dev
      podman-compose # start group of containers for dev
    ];
  };

  # Setup home-manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users = { "ch1n3du" = import ./home.nix; };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Enable CUDA support
  nixpkgs.config.cudaSupport = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    gnupg
    mangohud # Overlay for montoring performance
    protonup
    lutris
    bottles
    gruvbox-gtk-theme
    wget
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/home/ch1n3du/.steam/root/compatibilitytools.d";
  };

  virtualisation.docker = { enable = true; };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    # dataDir = "/data/postgresql";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall = {
    enable = true;

    # Open ports in the firewall.
    # allowedTCPPorts = [ ... ];
    allowedUDPPorts = [ 5353 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
