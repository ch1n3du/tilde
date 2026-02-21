{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.sshTunnels;

  # helper function to create a systemd service for each tunnel
  mkTunnelService = tunnel: {
    name = "ssh-tunnel-${tunnel.name}";
    value = {
      description = "SSH Tunnel ${tunnel.name} (${tunnel.server_hostname}:${toString tunnel.server_port} -> localhost:${toString tunnel.local_port})";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.openssh}/bin/ssh \
            -N \
            -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 \
            -o ExitOnForwardFailure=yes \
            -o StrictHostKeyChecking=accept-new \
            -o ControlMaster=no \
            ${optionalString (tunnel.identity_file != null) "-i ${tunnel.identity_file}"} \
            -L 127.0.0.1:${toString tunnel.local_port}:localhost:${toString tunnel.server_port} \
            ${tunnel.ssh_username}@${tunnel.server_hostname}
        '';
        Restart = "always";
        RestartSec = "10s";
        User = tunnel.service_user;
        PrivateNetwork = false;

        # additional hardening options
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        NoNewPrivileges = true;
      };
    };
  };

  tunnelOptions = {
    options = {
      name = mkOption {
        type = types.str;
        description = "Unique name for this tunnel (used in service name)";
        example = "customer1";
      };

      server_hostname = mkOption {
        type = types.str;
        description = "The hostname or IP address of the SSH server";
        example = "nabu.local";
      };

      server_port = mkOption {
        type = types.port;
        description = "The port on the remote server to forward";
        example = 8000;
      };

      ssh_username = mkOption {
        type = types.str;
        description = "Username for SSH authentication";
        example = "ch1n3du";
      };

      local_port = mkOption {
        type = types.port;
        description = "Local port to bind the tunnel to";
        example = 8000;
      };

      service_user = mkOption {
        type = types.str;
        default = "root";
        description = "System user to run the SSH tunnel service as";
      };

      identity_file = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to SSH identity file (private key) for authentication";
        example = "/home/ch1n3du/.ssh/ch1n3du-sshkey";
      };
    };
  };

in
{
  options.services.sshTunnels = {
    enable = mkEnableOption "SSH tunnel services";

    tunnels = mkOption {
      type = types.listOf (types.submodule tunnelOptions);
      default = [ ];
      description = "List of SSH tunnels to create";
      example = literalExpression ''
        [
          {
            name = "customer1";
            server_hostname = "nabu.local";
            server_port = 8000;
            ssh_username = "ch1n3du";
            local_port = 8000;
            service_user = "ch1n3du";
            identity_file = "/home/ch1n3du/.ssh/ch1n3du-sshkey";
          }
          {
            name = "database";
            server_hostname = "db.example.com";
            server_port = 5432;
            ssh_username = "dbuser";
            local_port = 5432;
            service_user = "postgres";
            identity_file = "/root/.ssh/db_key";
          }
          {
            name = "webserver";
            server_hostname = "10.0.1.50";
            server_port = 80;
            ssh_username = "admin";
            local_port = 8080;
            # Uses default service_user = "root"
            # identity_file = null means use default SSH key resolution
          }
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    # validate that tunnel names are unique
    assertions = [
      {
        assertion =
          let
            names = map (t: t.name) cfg.tunnels;
            uniqueNames = unique names;
          in
          length names == length uniqueNames;
        message = "SSH tunnel names must be unique. Duplicate names found: ${
          toString (subtractLists (unique (map (t: t.name) cfg.tunnels)) (map (t: t.name) cfg.tunnels))
        }";
      }
    ];

    systemd.services = listToAttrs (map mkTunnelService cfg.tunnels);

    environment.systemPackages = [ pkgs.openssh ];
  };
}
