{
  config,
  pkgs,
  lib,
  ...
}:

# vast.ai workflow: static SSH defaults for every instance, plus `vastutils`
# which generates per-instance aliases and manages per-instance deploy keys.
# See docs/vast.md.

let
  cfg = config.tilde.vast;

  vastutils = pkgs.writeShellApplication {
    name = "vastutils";
    runtimeInputs = with pkgs; [
      vastai
      gh
      jq
      openssh
      coreutils
      gawk
      gnugrep
      gnused
    ];
    text = ''
      : "''${VASTUTILS_IDENTITY_FILE:=${cfg.identityFile}}"
    ''
    + builtins.readFile ./vastutils.sh;
  };
in
{
  options.tilde.vast = {
    enable = lib.mkEnableOption "vast.ai SSH aliases and vastutils";

    identityFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/for_vastai";
      description = "Private key whose public half is registered with the vast.ai account.";
    };

    localForwards = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 8080 ];
      description = "Ports forwarded from localhost to the instance's localhost on interactive connections.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.vastai
      pkgs.gh
      vastutils
    ];

    # HostName/Port are deliberately absent: `vastutils sync` writes them to
    # ~/.ssh/config.d/vast.conf, which is included after this block. ssh takes
    # the first value it sees for each option, so the two never conflict.
    programs.ssh.matchBlocks.vast = {
      host = "vast vast-* *.vast.ai";
      user = "root";
      identityFile = cfg.identityFile;
      identitiesOnly = true;
      # Never forward the agent to rented hardware; use `vastutils bootstrap`.
      forwardAgent = false;
      localForwards = map (p: {
        bind.port = p;
        host.address = "localhost";
        host.port = p;
      }) cfg.localForwards;
      extraOptions = {
        # Instances are disposable and reuse proxy ports; keep their host keys
        # out of the main known_hosts.
        UserKnownHostsFile = "~/.ssh/known_hosts.vast";
        StrictHostKeyChecking = "accept-new";
        # Vast images lack ghostty/kitty terminfo.
        SetEnv = "TERM=xterm-256color";
      };
    };
  };
}
