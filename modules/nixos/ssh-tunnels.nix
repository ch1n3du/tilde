{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.sshTunnels;

  # Helper function to create a systemd service for each tunnel
  mkTunnelService = name: tunnel: {
    name = "ssh-tunnel-${name}";
    value = {
      description = "SSH Tunnel for ${name} (${tunnel.server_hostname}:${tunnel.server_port} -> localhost:${toString tunnel.local_port})";
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

        # Additional hardening options
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        NoNewPrivileges = true;
      };
    };
  };

  tunnelOptions = {
    options = {
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
        example = "/home/ch1n3du/.ssh/id_ed25519 ";
      };
    };
  };

in
{
  options.services.sshTunnels = {
    enable = mkEnableOption "SSH tunnel services";

    tunnels = mkOption {
      type = types.attrsOf (types.submodule tunnelOptions);
      default = { };
      description = "SSH tunnels to create";
      example = literalExpression ''
        {
          customer1 = {
            server_hostname = "anhing0";
            server_port = 8000;
            ssh_username = "mixrank";
            local_port = 8000;
            service_user = "mixrank";
            identity_file = "/home/mixrank/.ssh/mixrank-sshkey";
          };
          
          database = {
            server_hostname = "db.example.com";
            server_port = 5432;
            ssh_username = "dbuser";
            local_port = 5432;
            service_user = "postgres";
            identity_file = "/root/.ssh/db_key";
          };
          
          webserver = {
            server_hostname = "10.0.1.50";
            server_port = 80;
            ssh_username = "admin";
            local_port = 8080;
            # Uses default service_user = "root"
            # identity_file = null means use default SSH key resolution
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services = listToAttrs (mapAttrsToList mkTunnelService cfg.tunnels);

    # ensure SSH client is installed
    environment.systemPackages = [ pkgs.openssh ];
  };
}
