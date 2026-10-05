{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # Zotero 10.0.4 in nixpkgs a7868a7 expects Firefox ESR 140.15 but is
  # packaged with ESR 153. Keep Zotero on the last known-good nixpkgs until
  # that mismatch is fixed upstream.
  zoteroPinned =
    builtins.addErrorContext
      "while evaluating Zotero pinned to nixpkgs 20b1ddd due to the Firefox ESR 140/153 mismatch"
      (inputs.nixpkgs-zotero.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zotero);
in
{
  imports = [ ../../modules/home-manager ];

  tilde.kitty.enable = true;
  tilde.ghostty.enable = true;
  tilde.switcheroo.enable = true;
  tilde.tmux.enable = true;
  tilde.starship.enable = true;
  tilde.atuin.enable = true;
  tilde.zsh.enable = true;
  tilde.git = {
    enable = true;
    email = "danielonyesoh@mixrank.com";
  };
  tilde.helix = {
    enable = true;
    configDir = ../../configs/helix;
    enableLanguagesConfig = true;
  };

  tilde.packages.extraPackages = with pkgs; [
    # GUI Apps
    discord
    firefox
    vscode
    zed-editor
    claude-code
    todoist-electron
    obsidian
    remnote
    slack
    zoteroPinned
    burpsuite
    google-chrome
    foliate
    spotify
    syncplay
    prismlauncher

    # Dev tools
    ripgrep
    gnumake
    gcc
    tree
    nodejs_22
    uv
    python313
    git
    jujutsu
    elan
    sox
    codex
    android-studio
    android-studio-tools
    vastai
    modal
    inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

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
  };
}
