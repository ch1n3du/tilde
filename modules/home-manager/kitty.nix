{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.kitty;
in
{
  options.tilde.kitty.enable = lib.mkEnableOption "kitty terminal";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      themeFile = "GruvboxMaterialDarkHard";
      font.size = 12;
      font.name = "MonaspiceNe Nerd Font";
      settings = {
        background_opacity = "1.0";
        disable_ligatures = "never";
      };
    };
  };
}
