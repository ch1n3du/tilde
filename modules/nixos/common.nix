{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  cfg = config.tilde.system;
in
{
  options.tilde.system = {
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "System hostname";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "NixOS state version";
    };
  };

  config = {
    # Boot
    boot.loader.systemd-boot.enable = true;

    # Nix settings
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };
    };

    # Networking
    networking.hostName = cfg.hostname;
    networking.networkmanager.enable = true;
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ 5353 ];
    };

    # DNS
    services.resolved.enable = true;

    # Timezone
    time.timeZone = "Africa/Lagos";

    # User
    users.users.ch1n3du = {
      isNormalUser = true;
      shell = pkgs.zsh;
    };

    # Shell
    programs.zsh.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Base system packages
    environment.systemPackages = with pkgs; [
      helix
      wget
    ];

    # SSH
    services.openssh.enable = true;

    # Home Manager boilerplate
    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      backupFileExtension = "backup";
    };

    system.stateVersion = cfg.stateVersion;
  };
}
