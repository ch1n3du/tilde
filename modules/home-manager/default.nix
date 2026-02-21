{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./kitty.nix
    ./tmux.nix
    ./starship.nix
    ./atuin.nix
    ./zsh.nix
    ./git.nix
    ./helix.nix
    ./packages.nix
  ];

  home.username = "ch1n3du";
  home.homeDirectory = "/home/ch1n3du";
  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;

  home.file.".gitignore_global".text = ''
    .jj/
  '';

  programs.home-manager.enable = true;
}
