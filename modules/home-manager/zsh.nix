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

      plugins = [
        {
          # from https://github.com/direnv/direnv/issues/443#issuecomment-2380714786
          name = "zsh-completion-sync";
          src = pkgs.fetchFromGitHub {
            owner = "BronzeDeer";
            repo = "zsh-completion-sync";
            rev = "7f0a68e5fa8081554161d0d330d7f2a52683705e";
            hash = "sha256-GMZ0W8d0Qd5EhrwA/SkeOqDzoUchxDermcTR0iKYP8M=";
          };
        }
      ];

      shellAliases = {
        cd = "z";
        cdl = "z -l";
        ll = "ls -l";
        ls = "eza";
        open-monthly-log = ''FILE=~/log/monthly/$(date +%Y-%m).md; [ -f "$FILE" ] || sed "s/YYYY-MM/$(date +%Y-%m)/" ~/log/monthly/template.md > "$FILE"; cd ~/log && hx "$FILE"'';
        sync-log = "git commit -a -m '...' && git push";
        nabu = "kitten ssh ch1n3du@nabu.local";
        ebisu = "kitten ssh ch1n3du@ebisu.local";
        ctesiphon = "kitten ssh ch1n3du@ctesiphon.local";
        update-system = ''
          nix flake update ~/Code/tilde    
          nixos-rebuild --flake ~/Code/tilde switch --sudo
        '';
      }
      // cfg.extraAliases;
    };
  };
}
