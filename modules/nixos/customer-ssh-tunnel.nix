{ lib, config, pkgs, ... }:

# let 
#   # An alias for fields in the `configuration.nix` that
#   # start with 'main-user'
#   cfg = config.customer-ssh-tunnel;
# in
# {
#   options.main-user = {
#     enable 
#       = lib.mkEnableOption "enable user module";

#     userName = lib.mkOption {
#       default = "mainuser";
#       description = ''
#         username
#       '';
#     };
#   };

#   config = lib.mkIf cfg.enable {
#     users.users.${cfg.userName} = {
#       isNormalUser = true;
#       initialPassword = "12345";
#       description = "main user";
#       # shell = pkgs.zsh;
#     };
#   };
# }

let
  cfg = config.customer-reports-ssh-tunnel;
in
{
  options.customer-reports-ssh-tunnel = {
    enable
      = lib.mkEnableOption "Enable a tunnel for SSH reporting";
    customerName = lib.mkOption
  };
}
