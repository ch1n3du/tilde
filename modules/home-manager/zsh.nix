{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.zsh;
in
{
  options.tilde.zsh = {
    enable = lib.mkEnableOption "zsh shell";
    extraAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional shell aliases to add on top of the base set";
    };
  };

  config = lib.mkIf cfg.enable {
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
        ];
      };

      shellAliases = {
        cd = "z";
        cdl = "z -l";
        ll = "ls -l";
        ls = "eza";
        open-monthly-log = ''FILE=~/log/monthly/$(date +%Y-%m).md; [ -f "$FILE" ] || sed "s/YYYY-MM/$(date +%Y-%m)/" ~/log/monthly/template.md > "$FILE"; cd ~/log && hx "$FILE"'';
        nabu = "kitten ssh ch1n3du@nabu.local";
        ebisu = "kitten ssh ch1n3du@ebisu.local";
        ctesiphon = "kitten ssh ch1n3du@ctesiphon.local";
      }
      // cfg.extraAliases;
    };
  };
}
