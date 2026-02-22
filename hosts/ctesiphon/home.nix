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
    email = "danielonyesoh@gmail.com";
  };
  tilde.helix = {
    enable = true;
    configDir = ../../configs/helix;
    enableLanguagesConfig = true;
  };

  tilde.packages.extraPackages = with pkgs; [
    # GUI Apps
    firefox
    vscode
    zed-editor
    claude-code
    todoist
    remnote
    discord
    telegram-desktop
    slack

    # Dev tools
    ripgrep
    gnumake
    gcc
    tree
    nodejs_22
    uv
    python313
    git

    # LSPs
    ruff
    basedpyright
    gopls
    nixd
    nixfmt
    typescript-language-server
    vscode-langservers-extracted
    marksman
  ];

  # SSH client configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      extraConfig = ''
        Match all
            Include config.d/*.conf
      '';
  };

  # SSH agent service
  services.ssh-agent.enable = true;

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };
}
