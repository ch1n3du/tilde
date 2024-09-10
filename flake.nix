{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mixrank.url = "path:/home/ch1n3du/Code/mixrank";
    # mixrank.url = "git+ssh://git@gitlab.com/mixrank/mixrank";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  # outputs = { self, mixrank, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {

    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/ebisu/configuration.nix
          inputs.home-manager.nixosModules.default
          # mixrank.nixosModules.dev-machine
        ];
      };
    };

  };
}
