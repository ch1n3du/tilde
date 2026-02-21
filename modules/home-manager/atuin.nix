{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.atuin;
in
{
  options.tilde.atuin.enable = lib.mkEnableOption "atuin shell history";

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
