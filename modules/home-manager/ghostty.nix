{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.ghostty;
in
{
  options.tilde.ghostty.enable = lib.mkEnableOption "ghostty terminal";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = "Gruvbox Dark Hard";
        font-family = "MonaspiceNe Nerd Font";
        font-size = 14;
        background-opacity = 1.0;
      };
    };
  };
}
