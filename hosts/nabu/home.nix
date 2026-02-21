{ config, pkgs, ... }:

{
  imports = [ ../../modules/home-manager ];

  tilde.kitty.enable = true;
  tilde.tmux.enable = true;
  tilde.starship.enable = true;
  tilde.atuin.enable = true;
  tilde.zsh.enable = true;
  tilde.git = {
    enable = true;
    email = "danielonyeso@mixrank.com";
  };
  tilde.helix = {
    enable = true;
    configDir = ../../configs/helix;
  };
  tilde.packages.extraPackages = with pkgs; [
    direnv
    nix-direnv
    vscodium
    slack
    obsidian
    todoist-electron
    discord
    remnote
    zotero
  ];

  # Nabu-only: deluge auth
  home.file.".config/deluge/auth/auth_file.txt".text = ''
    ch1n3du:waowwaowwaow:10
  '';
}
