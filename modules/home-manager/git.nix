{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.git;
in
{
  options.tilde.git = {
    enable = lib.mkEnableOption "git";
    email = lib.mkOption {
      type = lib.types.str;
      default = "me@ch1n3du.net";
      description = "Email address for git commits";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Daniel Chinedu Onyesoh";
          email = cfg.email;
        };
        alias = {
          co = "checkout";
          st = "status";
          br = "branch";
          ci = "commit";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}
