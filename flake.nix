{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    mixrank.url = "git+ssh://git@gitlab.com/mixrank/mixrank";
    # mixrank.url = "git+file:///home/ch1n3du/Code/mixrank";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      mixrank,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        ch1n3du-ebisu-nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/ebisu/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.mixrank.nixosModules.dev-machine
            (
              { pkgs, ... }:
              {
                # Force the system to use the latest Nix version
                # nix.package = pkgs.nixVersions.latest;
                nix.package = pkgs.nixVersions.nix_2_24;
                # Enable flakes and new commands
                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
              }
            )
          ];
        };
        nabu = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/nabu/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.mixrank.nixosModules.dev-machine
          ];
        };
      };
    };
}
