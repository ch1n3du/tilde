{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.helix;
in
{
  options.tilde.helix = {
    enable = lib.mkEnableOption "helix editor config";
    configDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to the helix config directory";
    };
    enableLanguagesConfig = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to symlink languages.toml (for LSP configs)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/helix/config.toml".source = "${cfg.configDir}/config.toml";
    home.file.".config/helix/languages.toml" = lib.mkIf cfg.enableLanguagesConfig {
      source = "${cfg.configDir}/languages.toml";
    };
  };
}
