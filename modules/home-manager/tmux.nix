{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.tmux;
in
{
  options.tilde.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 100000;
      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.gruvbox
        tmuxPlugins.yank
        tmuxPlugins.vim-tmux-navigator
      ];
    };
  };
}
