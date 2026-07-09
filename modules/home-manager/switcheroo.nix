{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.tilde.switcheroo;

  switcheroo = pkgs.writeShellApplication {
    name = "switcheroo";
    runtimeInputs = with pkgs; [
      jujutsu
      nvd
      nix-output-monitor
      libnotify
    ];
    text = ''
      FLAKE_DIR="${cfg.flakeDir}"
      TARGET="${cfg.flakeTarget}"
      if [[ -z "$TARGET" ]]; then TARGET="$(hostname)"; fi

      # Update the flake lockfile unless called with -f/--fast.
      if [[ "''${1:-}" = "-f" || "''${1:-}" = "--fast" ]]; then
        echo "skipping lockfile update..."
      else
        cd "$FLAKE_DIR"
        # Snapshot the working copy in a fresh jj change before bumping inputs.
        if [[ $(jj diff --name-only | wc -l) -ne 0 ]]; then jj new; fi
        nix flake update
      fi

      # Build in a scratch dir so the ./result symlink never dirties the repo.
      BUILD_DIR="$(mktemp -d)"
      cd "$BUILD_DIR"
      echo "building .#$TARGET in $BUILD_DIR..."
      nixos-rebuild build --flake "$FLAKE_DIR#$TARGET" --log-format internal-json -v |& nom --json

      nvd diff /run/current-system ./result

      notify-send yo 'got a minute?' || true
      read -r -p "switch to .#$TARGET? [y/N] " response
      if [[ "$response" = "y" ]]; then
        sudo nixos-rebuild switch --flake "$FLAKE_DIR#$TARGET" --log-format internal-json -v |& nom --json
      fi
    '';
  };
in
{
  options.tilde.switcheroo = {
    enable = lib.mkEnableOption "switcheroo nixos-rebuild helper";

    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Code/tilde";
      description = "Path to the flake repository switcheroo operates on.";
    };

    flakeTarget = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        The nixosConfigurations attribute to build. When empty, switcheroo
        falls back to $(hostname) at runtime.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ switcheroo ];
  };
}
