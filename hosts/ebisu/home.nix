{ config, pkgs, ... }:

{
  imports = [ ../../modules/home-manager ];

  tilde.kitty.enable = true;
  tilde.tmux.enable = true;
  tilde.starship.enable = true;
  tilde.atuin.enable = true;
  tilde.zsh = {
    enable = true;
    extraAliases = {
      nabu = "kitten ssh ch1n3du@nabu.local";
      open-monthly-log = ''cd ~/log && hx "monthly/$(date +%Y-%m).md"'';
    };
  };
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
    zotero
    obsidian
    thunderbird
    slack
    vscode
    vlc
    todoist-electron
    discord
    qbittorrent
    gnome-tweaks
    spotify
    arduino-ide
    foliate
    remnote
    code-cursor
    google-chrome
    firefox
    openvpn
    telegram-desktop

    # Dev tools
    gpustat
    gnumake
    gcc
    cmake
    typst
    nodejs_22
    uv
    qemu
    python313
    yarn
    hugo
    ripgrep
    scc
    tree
    sqlite
    claude-code
    unixtools.netstat
    clang-tools
    nix-prefetch-git

    # LSPs
    ruff
    ty
    basedpyright
    gopls
    golangci-lint-langserver
    delve
    nixd
    nixfmt
    typescript-language-server
    vscode-langservers-extracted
    marksman
    clojure
    clojure-lsp

    # Drivers
    xdg-desktop-portal
    xdg-desktop-portal-gnome
  ];

  # Zed editor
  programs.zed-editor = {
    enable = true;
    extensions = [ "Python LSP" ];
    userSettings = {
      auto_update = true;
      helix_mode = true;
      ui_font_size = 14;
    };
  };

  # Jujutsu
  programs.jujutsu = {
    enable = true;
    settings = {
      user.email = "danielonyesoh@gmail.com";
      user.name = "Daniel Onyesoh";
      ui.paginate = "never";
    };
  };

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
        identityFile = "~/.ssh/ch1n3du-q3-2025-sshkey";
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        identityFile = "~/.ssh/ch1n3du-q3-2025-sshkey";
      };
      "f15_dev_user" = {
        hostname = "f15";
        user = "danielonyeso";
        extraOptions = {
          RemoteCommand = "cd mixrank && nix-shell -p tmux helix";
          RequestTTY = "yes";
        };
      };
    };
    extraConfig = ''
      Match all
          Include config.d/*.conf
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  # SSH agent service
  services.ssh-agent.enable = true;
}
