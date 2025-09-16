{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    mixrank = {
      url = "git+ssh://git@gitlab.com/mixrank/mixrank";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
