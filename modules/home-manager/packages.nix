{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.packages;
in
{
  options.tilde.packages.extraPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = "Additional packages to install on top of the common set";
  };

  config = {
    home.packages =
      with pkgs;
      [
        # Terminal apps
        kitty
        neofetch
        bat
        htop
        zoxide
        tmux
        zsh
        glow
        openssl
        unzip
        eza
        go
        rustup

        # Fonts
        inter
        nerd-fonts.code-new-roman
        nerd-fonts.fira-code
        nerd-fonts.monaspace
      ]
      ++ cfg.extraPackages;
  };
}
