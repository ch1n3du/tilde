{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ch1n3du";
  home.homeDirectory = "/home/ch1n3du";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable fonts
  fonts.fontconfig.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.zotero_7
    pkgs.obsidian
    pkgs.thunderbird
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.slack
    pkgs.vscodium
    pkgs.vlc
    pkgs.appimage-run
    pkgs.bitwarden-desktop
    pkgs.gearlever
    pkgs.zed-editor
    pkgs.todoist-electron
    pkgs.protonvpn-gui
    pkgs.discord
    pkgs.onlyoffice-bin
    pkgs.bottles
    pkgs.anki-bin


    pkgs.kitty
    pkgs.neofetch
    pkgs.bat
    pkgs.htop
    pkgs.lazygit
    pkgs.zoxide
    pkgs.gpustat
    pkgs.tmux
    pkgs.zsh
    pkgs.jujutsu
    pkgs.direnv
    pkgs.nix-direnv
    pkgs.glow
    pkgs.gnumake

    # Fonts
    pkgs.inter
    (pkgs.nerdfonts.override {
        fonts = ["CodeNewRoman" "FiraCode" "Monaspace"];
    })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".gitignore_global".text = ''
      .jj/
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ch1n3du/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "neovim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    themeFile = "GruvboxMaterialDarkHard";
    font.size = 12;
    font.name = "MonaspiceNe Nerd Font";

    settings = {
      background_opacity = "1.0";
      disable_ligatures = "never"; # Enable font ligatures
    };
  };

  # Configure zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "z"
        # "zsh-autosuggestions"
      ];
      # theme = "robbyrussell";
    };

    shellAliases = {
      cd = "z";
      cdl = "z -l";
      ll = "ls -l";
      mochi =  "appimage-run ~/AppImages/mochi.appimage";
    };
  };

  # Enable Git
  programs.git = {
    enable = true;
    userName = "Daniel Onyesoh";
    userEmail = "danielonyesoh@gmail.com";
    aliases = {
      co = "checkout";
      st = "status";
      br = "branch";
      ci = "commit";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      # url = {
      #   "git@github.com" = {
      #     insteadOf = "https://github.com/";
      #   };
      # };
    };
  };

  # Enable atuin
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  # Enable starship
  programs.starship = {
    enable = true;

    settings = {
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      hostname = {
        ssh_only = false;
        format = "[$hostname](bold #71e968): ";
      };
      username = {
        show_always = true;
        format = "[$user](bold #c09bf6)@";
      };
    };
  };

}
