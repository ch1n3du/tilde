{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.starship;
in
{
  options.tilde.starship.enable = lib.mkEnableOption "starship prompt";

  config = lib.mkIf cfg.enable {
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
  };
}
